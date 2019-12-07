package com.gigateam.heron.display.layer2d.layout 
{
	import com.gigateam.heron.AssetLoader;
	import com.gigateam.heron.display.util.Cloner;
	import com.gigateam.heron.events.WheelEvent;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.text.TextOptions;
	import starling.textures.Texture;
	import starling.utils.Align;
	import starling.utils.RectangleUtil;
	/**
	 * ...
	 * @author Tiger
	 */
	public class LayoutBuilder 
	{
		public var textFilter:ITextFilter;
		private var _scaleFactory:Number = 1;
		private var _dragScroller:DragScroller;
		private var _expectedWidth:int = 0;
		private var _expectedHeight:int = 0;
		private var _tree:LayoutNode;
		private var _src:XML;
		private var _loader:AssetLoader;
		private var _juggler:Juggler;
		private var _width:int;
		private var _height:int;
		public function LayoutBuilder(src:XML, assetLoader:AssetLoader, juggler:Juggler=null) 
		{
			_src = src;
			_loader = assetLoader;
			
			if (juggler == null){
				_juggler = Starling.juggler;
			}else{
				_juggler = juggler;
			}
			_dragScroller = new DragScroller(10, _juggler);
		}
		public function expected(width:uint, height:uint):void{
			_expectedWidth = width;
			_expectedHeight = height;
		}
		public function build():Sprite{
			var s:Sprite = new Sprite();
			_tree = new LayoutNode(s, _src);
			parsing(_src, _tree);
			return s;
		}
		private function onMouseWheel(e:MouseEvent):void{
			var node:LayoutNode = nodeOn(e.stageX, e.stageY);
			if (node == null){
				return;
			}
			var evt:WheelEvent = new WheelEvent(WheelEvent.MOUSE_WHEEL, true);
			evt.delta = e.delta;
			node.obj.dispatchEvent(evt);
		}
		public function get root():LayoutNode{
			return _tree;
		}
		/*
		 * High level
		 */
		public function getNodeById(id:String):LayoutNode{
			if (_tree == null){
				return null;
			}
			return _tree.getNodeById(id, true);
		}
		
		protected function parsing(xml:XML, treeNode:LayoutNode):void{
			var children:XMLList = xml.children();
			var scrollContainerCount:int = 0;
			var node:LayoutNode;
			for each (var item:XML in children)
			{
				var parent:DisplayObjectContainer = treeNode.obj as DisplayObjectContainer;
				switch(item.name().toString().toLowerCase()){
					case NodeTemplate.BUTTON:
						var upState:Texture = _loader.getSubTexture(item.@src.toString());
						var downState:Texture = _loader.getSubTexture(item.@down.toString());
						var overState:Texture = _loader.getSubTexture(item.@over.toString());
						var btn:Button = new Button(upState, "", downState, overState);
						node = new LayoutNode(btn, item);
						treeNode.add(node, true);
						break;
					case NodeTemplate.TEXT:
						var trim:String = item.@trim.toString();
						var tf:TextField;
						var text:String = item.toString();
						if (textFilter != null){
							text = textFilter.filter(text);
						}
						trace("text", text);
						if (trim != null && trim.toLowerCase() == "true"){
							var options:TextOptions = new TextOptions(false, true);
							tf = new AutoScaleTextField(800, 200, text, null, options);
						}else{
							tf = new TextField(1, 1, text);
						}
						node = new LayoutNode(tf, item);
						treeNode.add(node, true);
						break;
					case NodeTemplate.MOVIE_CLIP:
						var mc:MovieClip = _loader.getMovieClip(item.@src.toString());
						_juggler.add(mc);
						//mc.play();
						treeNode.addRaw(item, mc, true);
						//parent.addChild(mc);
						break;
					case NodeTemplate.IMAGE:
						var image:Image = _loader.getImage(item.@src.toString());
						treeNode.addRaw(item, image, true);
						//parent.addChild(image);
						break;
					case NodeTemplate.SPRITE:
						var s:Sprite = new Sprite();
						node = new LayoutNode(s, item);
						parsing(item, node);
						treeNode.add(node, true);
						if (node.scrollable){
							scrollContainerCount++;
						}
						//parent.addChild(s);
						break;
				}
			}
			if (scrollContainerCount > 0){
				Starling.current.nativeStage.addEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
				_dragScroller.start(_tree);
			}
		}
		
		public function clone(node:LayoutNode):LayoutNode{
			if (node.parent == null){
				return null;
			}
			var cloned:LayoutNode;
			var index:int = node.parent.indexOf(node);
			if (node.obj is Sprite){
				var s:Sprite = Cloner.cloneSprite(node.obj as Sprite);
				cloned = new LayoutNode(s, node.xml);
				parsing(node.xml, cloned);
				node.parent.add(cloned, true, index);
			}else if (node.obj is Image){
				var img:Image = Cloner.cloneImage(node.obj as Image);
				cloned = node.parent.addRaw(node.xml, img, true, index);
			}else if (node.obj is TextField){
				var tf:TextField = Cloner.cloneText(node.obj as TextField);
				cloned = node.parent.addRaw(node.xml, tf, true, index);
			}else if (node.obj is MovieClip){
				var mc:MovieClip = _loader.getMovieClip(node.xml.@src.toString());
				cloned = node.parent.addRaw(node.xml, mc, true, index);
			}
			return cloned;
		}
		/*
		 * Two steps to do whole reflow
		 * 1.Get primitive(non-container) content bounds, and update parent, then builder known the min-size of all container
		 * 2.Percentage is inheritant value, so recursively update children from parent if percentage-based value.
		 */
		public function resize(width:int=0, height:int=0, scaleFactory:Number=0):Number{
			var rootBounds:Rectangle = calculateBounds(_tree);
			if (width == 0){
				width = _width;
			}else{
				_width = width;
			}
			if (height == 0){
				height = _height;
			}else{
				_height = height;
			}
			if (scaleFactory == 0){
				scaleFactory = _scaleFactory;
			}else{
				_scaleFactory = scaleFactory;
				
				if (_dragScroller != null){
					_dragScroller.scaleFactory = _scaleFactory;
				}
			}
			alignAndSize(_tree, new Rectangle(0, 0, width / scaleFactory, height / scaleFactory));
			_tree.scale = scaleFactory;
			//trace(_scaleFactor, _expectedWidth , _expectedHeight, width , height);
			return scaleFactory;
		}
		private function enableScroll(node:LayoutNode):void{
			node.scrollbarVisible = true;
		}
		private function disableScroll(node:LayoutNode):void{
			node.scrollbarVisible = false;
		}
		protected function alignAndSize(node:LayoutNode, pBound:Rectangle, contentBound:Rectangle=null):void{
			node.overflow = false;
			if (contentBound == null){
				contentBound = pBound.clone();
			}
			
			var outerRelative:Boolean = false;
			var conBound:Rectangle = contentBound;
			var inheritWidth:int = contentBound.width * node.width;
			var inheritHeight:int = contentBound.height * node.height;
			
			var cBound:Rectangle = node.bounds;
			if (node.background != ""){
				updateAspect(node, pBound);
			}else{
				switch(node.scrollElement){
					case "scrollbar-thumb":
					case "scrollbar-track":
						outerRelative = true;
						conBound = pBound;
						node.updateRelativeWidth(conBound.width);
						node.updateRelativeHeight(conBound.height);
						break;
					default:
						node.updateRelativeWidth(conBound.width);
						node.updateRelativeHeight(conBound.height);
						break;
				}
				
				if(node.scrollable){
					if (node.overflow){
						enableScroll(node);
					}else{
						disableScroll(node);
					}
				}
			}
			//Alignment
			if(node.align!="none"){
				if (node.left >= 0){
					if (node.left <= 1){
						try{
							node.obj.x = conBound.left + (conBound.width - cBound.width) * node.left;
						}catch (e:Error){
							trace("error!",node.id,node, node.obj, conBound, cBound);
						}
					}else{
						node.obj.x = node.left;
					}
				}else if (node.right > 1){
					if (node.right <= 1){
						node.obj.x = conBound.left + (conBound.width - cBound.width) * (1-node.right);
					}else{
						node.obj.x = conBound.right - cBound.width - node.right;
					}
				}
				//cBound.left = node.obj.x;
			}
			
			if(node.vAlign!="none"){
				if (node.bottom > 1){
					if (node.bottom <= 1){
						//node.obj.y = conBound.bottom - cBound.height - node.bottom;
						node.obj.y = conBound.top + (conBound.height - cBound.height) * (1-node.bottom);
					}else{
						node.obj.y = conBound.bottom - cBound.height - node.bottom;
					}
				} else if (node.top >= 0){
					if (node.top <= 1){
						node.obj.y = conBound.top + (conBound.height - cBound.height) * node.top;
					}else{
						node.obj.y = node.top;
					}
				}
				//cBound.top = node.obj.y;
			}
			
			if (node.primitive){
				node.obj.width = cBound.width;
				node.obj.height = cBound.height;
			}else{
				var i:int;
				for (i = 0; i < node.children.length; i++){
					var child:LayoutNode = node.childAt(i);
					alignAndSize(child, node.bounds, node.contentBounds);
				}
				if(node.mask){
					var mask:DisplayObject = node.obj.mask;
					mask.width = node.bounds.width;
					mask.height = node.bounds.height;
				}
			}
		}
		public static function updateAspect(node:LayoutNode, refBounds:Rectangle):void{
			if (isAlignWidth(node.bounds, refBounds, node.background=="contain")){
				alignAspectWidth(node.bounds, refBounds);
			}else{
				alignAspectHeight(node.bounds, refBounds);
			}
			node.obj.width = node.bounds.width;
			node.obj.height = node.bounds.height;
		}
		public static function isAlignWidth(bounds:Rectangle, refBounds:Rectangle, isContain:Boolean):Boolean{
			var biggerRatio:Boolean = (bounds.width / bounds.height) > (refBounds.width / refBounds.height);
			return biggerRatio == isContain;
		}
		public static function alignAspectWidth(bounds:Rectangle, refBounds:Rectangle):void{
			var ratio:Number = bounds.width / bounds.height;
			bounds.width = refBounds.width;
			bounds.height = bounds.width / ratio;
		}
		public static function alignAspectHeight(bounds:Rectangle, refBounds:Rectangle):void{
			var ratio:Number = bounds.width / bounds.height;
			bounds.height = refBounds.height;
			bounds.width = bounds.height * ratio;
		}
		protected function calculateBounds(node:LayoutNode):Rectangle{
			if (!node.visible){
				//return new Rectangle(0, 0, 1, 1);
			}
			if (node.primitive || node.generic){
				if (node.width > 0){
					node.obj.width = node.width;
				}
				if (node.height > 0){
					node.obj.height = node.height;
				}
				
				node.innerBounds = node.obj.bounds;
				return node.obj.bounds;
			}
			//Calculating maxrect
			var intersecting:Rectangle;
			var bounds:Rectangle;
			var i:int;
			var accumulate:int = 0;
			
			switch(node.block){
				case "vertical":
					accumulate = node.paddingTop;
					break;
				case "horizontal":
					accumulate = node.paddingLeft;
					break;
			}
			for (i = 0; i < node.children.length; i++){
				var child:LayoutNode = node.childAt(i);
				
				child.obj.x = 0;
				child.obj.y = 0;
				bounds = calculateBounds(child);
				if (child.float){
					continue;
				}else if (bounds == null){
					bounds = new Rectangle(0, 0, 1, 1);
				}
				switch(node.block){
					case "vertical":
						//bounds = bounds.clone();
						bounds.y = accumulate;
						if(child.primitive){
							child.obj.y = bounds.y;
						}
						child.vAlign = "none";
						accumulate+= bounds.height;
						break;
					case "horizontal":
						bounds.x = accumulate;
						if(child.primitive){
							child.obj.x = bounds.x;
						}
						child.align = "none";
						accumulate+= bounds.width;
						break;
				}
				
				if (intersecting == null){
					intersecting = bounds.clone();
				}else{
					//Calc max rect of children
					if (bounds.left < intersecting.left){
						intersecting.left = bounds.left;
					}
					if (bounds.right > intersecting.right){
						intersecting.right = bounds.right;
					}
					
					if (bounds.top < intersecting.top){
						intersecting.top = bounds.top;
					}
					if (bounds.bottom > intersecting.bottom){
						intersecting.bottom = bounds.bottom;
					}
				}
			}
			//Replace actual width and height only setting bigger than calculated
			if (intersecting == null){
				intersecting = new Rectangle(0, 0, 1, 1);
			}
			replaceSize(intersecting, node.width, node.height);
			
			intersecting.width += node.paddingLeft + node.paddingRight;
			intersecting.height += node.paddingTop + node.paddingBottom;
			intersecting.x = 0;
			intersecting.y = 0;

			//trace(intersecting, node.id);
			
			node.innerBounds = intersecting;
			if (node.scrollable){
				if (!node.isVecticalScroll && node.width <= 1 && node.width > 0){
					node.bounds.width = 1;
				}else{
					node.bounds.width = node.innerBounds.width;
				}
				if (node.isVecticalScroll && node.height <= 1 && node.height >0){
					node.bounds.height = 1;
				}else{
					node.bounds.height = node.innerBounds.height;
				}
			}
			return node.bounds;
		}
		public function remove(node:LayoutNode):void{
			node.parent.remove(node);
		}
		protected static function replaceSize(bounds:Rectangle, width:int, height:int):void{
			if (width > bounds.width){
				bounds.width = width;
			}
			if (height > bounds.height){
				bounds.height = height;
			}
		}
		public function unbuild():void{
			Starling.current.nativeStage.removeEventListener(MouseEvent.MOUSE_WHEEL, onMouseWheel);
			if(_dragScroller!=null){
				_dragScroller.stop();
			}
		}
		public function dispose():void{
			if (root.obj != null && root.obj.parent != null && root.obj.parent.contains(root.obj)){
				root.obj.parent.removeChild(root.obj);
			}
			unbuild();
			root.dispose();
		}
		public function nodeOn(x:int, y:int):LayoutNode{
			if (_tree.obj.stage == null){
				return null;
			}
			var rect:Rectangle = new Rectangle();
			return positionOnNode(_tree, x, y, rect);
		}
		public static function positionOnNode(node:LayoutNode, globalX:int, globalY:int, rect:Rectangle, filter:ICapturingFilter=null):LayoutNode{
			node.obj.getBounds(node.obj.stage, rect);
			if (globalX < rect.left || globalX > rect.right || globalY < rect.top || globalY > rect.bottom || !node.visible){
				return null;
			}
			var i:int = node.numChildren;
			while(i>0){
				i--;
				var child:LayoutNode = positionOnNode(node.childAt(i), globalX, globalY, rect, filter);
				if (child != null && child.touchable){
					if (filter == null){
						return child;
					}else{
						var res:Boolean = filter.suitable(child);
						if (res){
							return child;
						}
					//if (filter == null || filter.suitable(child)){
						//return child;
					}
				}
			}
			return node;
		}
	}
}