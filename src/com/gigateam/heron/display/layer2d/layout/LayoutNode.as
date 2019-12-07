package com.gigateam.heron.display.layer2d.layout 
{
	import com.gigateam.heron.display.util.Cloner;
	import com.gigateam.heron.events.UIEvent;
	import com.gigateam.heron.events.WheelEvent;
	import com.gigateam.world.physics.algorithm.Equation;
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import starling.animation.Juggler;
	import starling.animation.Transitions;
	import starling.animation.Tween;
	import starling.display.Button;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Quad;
	import starling.display.Sprite;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	import starling.text.TextField;
	import starling.utils.Align;
	/**
	 * ...
	 * @author Tiger
	 */
	public class LayoutNode extends EventDispatcher
	{
		public var data:Object = {};
		
		public static var defaultFont:String = "Verdana";
		private var _juggler:Juggler;
		
		private var _parent:LayoutNode;
		private var _children:Vector.<LayoutNode>;
		private var _xml:XML;
		private var _obj:DisplayObject;
		private var _primitive:Boolean = true;
		private var _innerBounds:Rectangle;
		public var bounds:Rectangle;
		public var width:Number = 0;
		public var height:Number = 0;
		public var top:Number = 0;
		public var left:Number = 0;
		public var right:Number = 0;
		public var bottom:Number = 0;
		public var id:String;
		private var _alpha:Number = 1;
		public var align:String;
		public var vAlign:String;
		
		public var textAlign:String;
		public var textVAlign:String;
		
		public var paddingTop:int;
		public var paddingRight:int;
		public var paddingBottom:int;
		public var paddingLeft:int;
		
		public var scale9top:int;
		public var scale9right:int;
		public var scale9bottom:int;
		public var scale9left:int;
		
		private var _clickable:Boolean = false;
		public var touchable:Boolean;
		public var float:Boolean;
		
		public var color:int = 0;
		public var size:int = 0;
		public var background:String;
		public var block:String;
		public var scrollElement:String;
		public var scrollable:Boolean = false;
		public var overflow:Boolean = false;
		public var generic:Boolean = false;
		public var mask:Boolean = false;
		public var trim:Boolean = false;
		private var _content:Sprite;
		
		private var _originalBounds:Rectangle;
		
		private var _scrollbarTrack:LayoutNode;
		private var _scrollbarThumb:LayoutNode;
		
		public function LayoutNode(obj:DisplayObject, xmlNode:XML=null) 
		{
			_xml = xmlNode;
			_obj = obj;
			
			var alphaStr:String = xmlNode.@alpha.toString();
			if(alphaStr!=""){
				_alpha = lengthToNumber(alphaStr);
			}
			generic = getBoolean(xmlNode.@generic.toString(), false);
			mask = getBoolean(xmlNode.@masked.toString(), false);
			clickable = getBoolean(xmlNode.@clickable.toString(), false);
			touchable = getBoolean(xmlNode.@touchable.toString(), true);
			trim = getBoolean(xmlNode.@trim.toString(), false);
			float = getBoolean(xmlNode.@float.toString(), false);
			width = lengthToNumber(xmlNode.@width.toString());
			height = lengthToNumber(xmlNode.@height.toString());
			top = lengthToNumber(xmlNode.@top.toString(), -1);
			left = lengthToNumber(xmlNode.@left.toString(), -1);
			bottom = lengthToNumber(xmlNode.@bottom.toString(), -1);
			right = lengthToNumber(xmlNode.@right.toString(), -1);
			align = xmlNode.@align.toString();
			vAlign = xmlNode.@valign.toString();
			textAlign = xmlNode.@textAlign.toString();
			textVAlign = xmlNode.@textVAlign.toString();
			id = xmlNode.@id.toString();
			block = xmlNode.@block.toString();
			background = xmlNode.@background.toString();
			scrollElement = xmlNode.@scroll.toString();
			color = hexToInt(xmlNode.@color.toString());
			size = Number(xmlNode.@size.toString());
			
			if (left < 0 && right < 0){
				align = align == ""?Align.LEFT:align;
				switch(align){
					case Align.LEFT:
						left = 0;
						break;
					case Align.CENTER:
						left = 0.5;
						break;
					case Align.RIGHT:
						left = 1;
						break;
				}
			}
			
			if (top < 0 && bottom < 0){
				vAlign = vAlign == ""?Align.TOP:vAlign;
				switch(vAlign){
					case Align.TOP:
						top = 0;
						break;
					case Align.CENTER:
						top = 0.5;
						break;
					case Align.BOTTOM:
						top = 1;
						break;
				}
			}
			
			if (left < 0 && right >= 0 && right <= 1){
				left = 1 - right;
				right = -1;
			}
			
			if (top < 0 && bottom >= 0 && bottom <= 1){
				top = 1 - bottom;
				bottom = -1;
			}
			
			var parsed:Vector.<int>;
			parsed = parseNumberSet(xmlNode.@padding.toString());
			paddingTop = parsed[0];
			paddingRight = parsed[1];
			paddingBottom = parsed[2];
			paddingLeft = parsed[3];
			
			parsed = parseNumberSet(xmlNode.@scale9.toString());
			scale9top = parsed[0];
			scale9right = parsed[1];
			scale9bottom = parsed[2];
			scale9left = parsed[3];
			
			if (_alpha != 1){
				obj.alpha = _alpha;
			}
			if (!touchable){
				obj.touchable = false;
			}
			
			switch(scrollElement){
				case "content":
					scrollable = true;
					break;
				case "scrollbar-track":
				case "scrollbar-thumb":
					if (isVecticalScroll){
						vAlign = "";
					}else{
						align = "";
					}
					float = true;
					break;
			}
			if (obj is Sprite){
				_primitive = false;
				
				//scrollable = getBoolean(xmlNode.@scroll.toString(), false);
				if (scrollable && block == ""){
					scrollable = false;
				}
				if (mask){
					obj.mask = new Quad(100, 100, 0);
				}
				var sprite:Sprite = obj as Sprite;
				if (scrollable){
					//sprite.addChild(sprite.mask);
					_content = new Sprite();
					//_content.mask = new Quad(100, 100, 0);
					sprite.addChild(_content);
				}else{
					_content = sprite;
				}
			}else{
				scrollable = false;
				_originalBounds = obj.bounds.clone();
				if (obj is TextField){
					var tf:TextField = obj as TextField;
					tf.format.font = defaultFont;
					tf.format.size = size > 12 ? size : 12;
					tf.format.color = color;
					switch(textAlign){
						case Align.CENTER:
						case Align.RIGHT:
							tf.format.horizontalAlign = textAlign;
							break;
						default:
							tf.format.horizontalAlign = Align.LEFT;
					}
					switch(textVAlign){
						case Align.CENTER:
						case Align.BOTTOM:
							tf.format.verticalAlign = textVAlign;
							break;
						default:
							tf.format.verticalAlign = Align.TOP;
					}
				}else if (((obj is Image) || (obj is Button)) && scale9sum > 0){
					
					var b:Rectangle;
					if (obj is Image){
						var img:Image = obj as Image;
						b = img.bounds;
						img.scale9Grid = new Rectangle(scale9left, scale9top, b.width - scale9left - scale9right, b.height - scale9top - scale9bottom);
					}else{
						var btn:Button = obj as Button;
						b = btn.bounds;
						btn.scale9Grid = new Rectangle(scale9left, scale9top, b.width - scale9left - scale9right, b.height - scale9top - scale9bottom);
					}
				}else if ((obj is Image) || (obj is MovieClip)){
					switch(background){
						case "cover":
							width = 0;
							height = 0;
							float = true;
							break;
						case "contain":
							width = 0;
							height = 0;
							break;
					}
				}
			}
		}
		public function get clickable():Boolean{
			return _clickable;
		}
		public function set clickable(b:Boolean):void{
			if (_clickable == b){
				return;
			}
			_clickable = b;
			if (_clickable){
				obj.addEventListener(TouchEvent.TOUCH, onTouch);
			}else{
				obj.removeEventListener(TouchEvent.TOUCH, onTouch);
			}
		}
		private function onTouch(e:TouchEvent):void{
			var t:Touch = e.getTouch(obj);
			if (t == null){
				return;
			}
			//e.stopImmediatePropagation();
			if (t.phase != TouchPhase.ENDED){
				return;
			}
			dispatchEvent(new UIEvent(UIEvent.TRIGGERED));
		}
		public function get scale():Number{
			return obj.scale;
		}
		public function set scale(s:Number):void{
			obj.scale = s;
		}
		public function get alpha():Number{
			return obj.alpha;
		}
		public function set alpha(a:Number):void{
			obj.alpha = a;
			_alpha = a;
		}
		public function get xml():XML{
			return _xml;
		}
		public function get parent():LayoutNode{
			return _parent;
		}
		public function get visible():Boolean{
			return obj.visible;
		}
		public function set visible(b:Boolean):void{
			obj.visible = b;
		}
		public function set scrollbarVisible(visiblility:Boolean):void{
			if (_scrollbarThumb != null){
				_scrollbarThumb.obj.visible = visiblility;
			}
			if (_scrollbarTrack != null){
				_scrollbarTrack.obj.visible = visiblility;
			}
		}
		public function get scrollbarVisible():Boolean{
			if (_scrollbarThumb != null){
				return _scrollbarThumb.obj.visible;
			}else if (_scrollbarTrack != null){
				return _scrollbarTrack.obj.visible;
			}
			return false;
		}
		public function get isVecticalScroll():Boolean{
			if (!scrollable){
				return false;
			}
			switch(block){
				case "vertical":
					return true;
					break;
			}
			return false;
		}
		public function set innerBounds(b:Rectangle):void{
			_innerBounds = b.clone();
			if(scrollable){
				bounds = _innerBounds.clone();
			}else{
				bounds = _innerBounds;
			}
		}
		public function get innerBounds():Rectangle{
			return _innerBounds;
		}
		public function get originalBounds():Rectangle{
			return _originalBounds;
		}
		public function get x():Number{
			if (primitive){
				return obj.x;
			}
			return bounds.x;
		}
		public function get y():Number{
			if (primitive){
				return obj.y;
			}
			return bounds.y;
		}
		public function get calcedWidth():Number{
			if (primitive){
				return obj.width;
			}
			if (bounds == null){
				return 0;
			}
			return bounds.width;
		}
		public function get aspectRatio():Number{
			return bounds.width / bounds.height;
		}
		public function updateRelativeWidth(parentLength:int):int{
			if (width <= 0 || width > 1){
				return width;
			}
			var inheritLength:int = parentLength * width;
			if (scrollable){
				if (!isVecticalScroll){
					if (inheritLength < innerBounds.width){
						overflow = true;
						bounds.width = inheritLength;
					}else{
						innerBounds.width = bounds.width=inheritLength;
					}
				}else if (inheritLength > bounds.width){
					innerBounds.width = bounds.width=inheritLength;
				}
			}else{
				if (inheritLength > bounds.width){
					innerBounds.width = inheritLength;
					//bounds.width = inheritLength;
				}
				//obj.width = inheritLength;
			}
			return inheritLength;
		}
		public function updateRelativeHeight(parentLength:int):int{
			if (height <= 0 || height > 1){
				return height;
			}
			var inheritLength:int = parentLength * height;
			if (scrollable){
				if(isVecticalScroll){
					if (inheritLength < innerBounds.height){
						overflow = true;
						bounds.height = inheritLength;
					}else{
						innerBounds.height = bounds.height=inheritLength;
					}
				}else if (inheritLength > bounds.height){
					innerBounds.height = bounds.height=inheritLength;
				}
			}else{
				if (inheritLength > bounds.height){
					innerBounds.height = inheritLength;
					//bounds.height = inheritLength;
				}

			}
			return inheritLength;
		}
		public function get contentBounds():Rectangle{
			var rect:Rectangle = _innerBounds.clone();
			rect.x += paddingLeft;
			rect.y += paddingTop;
			rect.width -= paddingLeft + paddingRight;
			rect.height -= paddingTop + paddingBottom;
			return rect;
		}
		private static function hexToInt(hex:String):int{
			return parseInt(hex, 16);
		}
		private static function lengthToNumber(length:String, defaultValue:Number=0):Number{
			var sp:Array = length.split("%");
			if (sp.length == 2){
				if (sp[1].length > 0){
					return 0;
				}
				if (sp[0] == ""){
					return defaultValue;
				}
				return Number(sp[0]) * 0.01;
			}
			if (sp[0] == ""){
				return defaultValue;
			}
			return Number(sp[0]);
		}
		private static function getBoolean(bool:String, defaultValue:Boolean=false):Boolean{
			switch(bool.toLowerCase()){
				case "true":
					return true;
				case "false":
					return false;
				default:
					return defaultValue;
			}
		}
		public function get primitive():Boolean{
			return _primitive;
		}
		public function set obj(o:DisplayObject):void{
			if (_obj.parent != null){
				var oParent:DisplayObjectContainer = _obj.parent;
				var i:int = oParent.getChildIndex(_obj);
				oParent.removeChild(_obj);
				oParent.addChildAt(o, i);
			}
			_obj = o;
		}
		public function get obj():DisplayObject{
			return _obj;
		}
		public function get content():Sprite{
			return _content;
		}
		public function childAt(index:int):LayoutNode{
			return children[index];
		}
		public function get numChildren():int{
			return children.length;
		}
		private function onWheel(e:WheelEvent):void{
			scroll(e.delta);
		}
		public function scrollTo(pos:int, overflowRatio:Number=0):void{
			if (!scrollable){
				return;
			}
			var results:Vector.<Number>;
			results = scrollAxisTo(pos, scrollerStart, scrollerEnd, overflowRatio);
			if (isVecticalScroll){
				content.y = results[0];
				if (_scrollbarThumb != null){
					_scrollbarThumb.obj.y = (bounds.height - _scrollbarThumb.obj.bounds.height) * results[1];
				}
			}else{
				content.x = results[0];
				if (_scrollbarThumb != null){
					_scrollbarThumb.obj.x = (bounds.width - _scrollbarThumb.obj.bounds.width) * results[1];
				}
			}
		}
		public function get scrollPos():int{
			return isVecticalScroll ? content.y : content.x;
		}
		public function set scrollPos(pos:int):void{
			scrollTo(pos, 1);
		}
		public function scroll(delta:int):void{
			if (!scrollable){
				return;
			}
			var magnitude:Number = -10;
			var percentage:Number = 0;
			
			var origin:int = isVecticalScroll ? content.y : content.x;
			scrollTo(origin - delta * magnitude);
			/*var start:int = scrollerStart;
			var end:int;
			var results:Vector.<Number>;
			if (isVecticalScroll){
				results = scrollAxis(content.y, delta * magnitude, start, scrollerEnd);
				content.y = results[0];
				if (_scrollbarThumb != null){
					_scrollbarThumb.obj.y = (bounds.height - _scrollbarThumb.obj.bounds.height) * results[1];
				}
			}else{
				results = scrollAxis(content.x, delta * magnitude, start, scrollerEnd);
				content.x = results[0];
				if (_scrollbarThumb != null){
					_scrollbarThumb.obj.x = (bounds.width - _scrollbarThumb.obj.bounds.width) * results[1];
				}

			}*/
		}
		private function get scrollerStart():Number{
			return 0;
		}
		private function get scrollerEnd():Number{
			if (isVecticalScroll){
				return bounds.bottom - innerBounds.height;
			}
			return bounds.right - innerBounds.width;
		}
		private static function scrollAxis(origin:int, delta:int, start:int, end:int):Vector.<Number>{
			origin -= delta;
			return scrollAxisTo(origin, start, end);
		}
		private static function scrollAxisTo(origin:int, start:int, end:int, overflowRatio:Number = 0):Vector.<Number>{
			var vec:Vector.<Number> = new Vector.<Number>();
			if (origin > start){
				origin = start - (start - origin) * overflowRatio;
			}else if (origin < end){
				origin = end - (end - origin) * overflowRatio;
			}
			vec.push(origin);
			var percentage:Number = (origin - start) / end;
			vec.push(percentage);
			return vec;
		}
		private function get overedflow():int{
			if (!scrollable){
				return 0;
			}
			if (isVecticalScroll){
				if (content.y > scrollerStart){
					return scrollerStart - content.y;
				}else if (content.y < scrollerEnd){
					return scrollerEnd - content.y;
				}
				return 0;
			}
			if (content.x > scrollerStart){
				return scrollerStart - content.x;
			}else if (content.x < scrollerEnd){
				return scrollerEnd - content.x;
			}
			return 0;
		}
		public function get children():Vector.<LayoutNode>{
			if (_children == null){
				_children = new Vector.<LayoutNode>();
			}
			return _children;
		}
		public function added():void{
			if (scrollable){
				obj.addEventListener(WheelEvent.MOUSE_WHEEL, onWheel);
			}
		}
		
		public function stopBounce():void{
			if (_juggler != null){
				_juggler.removeTweens(this);
			}
			var offset:int = overedflow;
			if (isVecticalScroll){
				//content.y += offset;
			}else{
				//content.x += offset;
			}
		}
		public function bounceBack(juggler:Juggler, velocity:Number):void{
			_juggler = juggler;
			if (!scrollable){
				return;
			}
			
			if (true){
				var friction:Number = -velocity*0.5;
				
				var duration:Number = Equation.axisExceedVelTime(velocity, friction, 0);
				var stopAt:int = scrollPos+Equation.axisDisplacement(velocity, friction, duration);
				var beginTween:Tween;
				var endValue:int;
				var transition:String;
				var distance:Number;
				if (stopAt > scrollerStart){
					if (scrollPos > scrollerStart){
						transition = Transitions.EASE_OUT;
						endValue = scrollerStart;
						duration = 0.2;
					}else{
						transition = Transitions.EASE_OUT_BACK;
						endValue = scrollerStart;
						distance = scrollerStart - scrollPos;
						duration = Equation.axisExceedPosTime( distance, velocity, friction);
						if (isNaN(duration)){
							Equation.axisExceedPosTime( scrollerStart-scrollPos, velocity, friction);
						}
					}
					
				}else if (stopAt < scrollerEnd){
					if (scrollPos < scrollerEnd){
						transition = Transitions.EASE_OUT;
						endValue = scrollerEnd;
						duration = 0.2;
					}else{
						transition = Transitions.EASE_OUT_BACK;
						endValue = scrollerEnd;
						distance = scrollerEnd - scrollPos;
						duration = Equation.axisExceedPosTime(-distance , -velocity, -friction);
					}
				}else{
					transition = Transitions.EASE_OUT;
					duration = Equation.axisExceedVelTime(velocity, friction, 0);
					endValue = scrollPos+Equation.axisDisplacement(velocity, friction, duration);
				}
				trace("release", endValue, scrollerStart, scrollerEnd, scrollPos);
				beginTween = new Tween(this, duration, transition);
				beginTween.animate("scrollPos", endValue);
				
				juggler.add(beginTween);
				return;
			}
			
			var offset:int = overedflow;
			if (isVecticalScroll){
				content.y += offset;
			}else{
				content.x += offset;
			}
			//tw.animate(
		}
		public function removed():void{
			if (scrollable){
				obj.removeEventListener(WheelEvent.MOUSE_WHEEL, onWheel);
			}
			if (obj.parent != null){
				obj.parent.removeChild(obj);
			}
		}
		public function indexOf(child:LayoutNode):int{
			return children.indexOf(child);
		}
		public function add(node:LayoutNode, addToDisplay:Boolean = false, index:int =-1):void{
			if (index >= 0){
				children.insertAt(index, node);
			}else{
				children.push(node);
			}
			var container:Sprite;
			container = content;
			switch(node.scrollElement){
				case "scrollbar-track":
					_scrollbarTrack = node;
					container = _obj as Sprite;
					break;
				case "scrollbar-thumb":
					_scrollbarThumb = node;
					container = _obj as Sprite;
					break;
			}
			if (addToDisplay){
				container.addChild(node.obj);
			}
			node._parent = this;
			node.added();
		}
		public function remove(node:LayoutNode):void{
			var i:int;
			for (i = 0; i < children.length; i++){
				if (childAt(i) == node){
					var child:LayoutNode = childAt(i);
					children.removeAt(i);
					child.removed();
					break;
				}
			}
		}
		public function clone():LayoutNode{
			var clonedObj:DisplayObject;
			if (obj is Sprite){
				clonedObj = new Sprite();
			}else if(obj is Image){
				clonedObj = Cloner.cloneImage(obj as Image);
			}else if(obj is TextField){
				clonedObj = Cloner.cloneText(obj as TextField);
			}
			var node:LayoutNode = new LayoutNode(clonedObj, _xml);
			return node;
		}
		public function addRaw(xmlNode:XML, obj:DisplayObject, addToDisplay:Boolean = false, index:int=-1):LayoutNode{
			var node:LayoutNode = new LayoutNode(obj, xmlNode);
			add(node, addToDisplay);
			return node;
		}
		public function dispose():void{
			var i:int;
			clickable = false;
			if(_children!=null){
				for (i = 0; i < _children.length; i++){
					_children[i].dispose();
				}
				_children = null;
			}
			_xml = null;
			_obj = null;
		}
		public function get scale9sum():int{
			return scale9bottom + scale9left + scale9right + scale9top;
		}
		public function getNodeByObject(object:DisplayObject, recursive:Boolean = true):LayoutNode{
			if (obj == object){
				return this;
			}
			var i:int;
			var child:LayoutNode;
			var child2:LayoutNode;
			for (i = 0; i < numChildren; i++){
				child = childAt(i);
				if (child.obj == object){
					return child;
				}
				if (child.numChildren > 0 && recursive){
					child2 = child.getNodeByObject(object, recursive);
					if (child2 != null){
						return child2;
					}
				}
			}
			return null;
		}
		public function getNodeById(id:String, recursive:Boolean=true):LayoutNode{
			var i:int;
			var child:LayoutNode;
			for (i = 0; i < numChildren; i++){
				child = childAt(i);
				if (child != null){
					if(child.id==id){
						return child;
					}else if(recursive){
						var grandchild:LayoutNode = child.getNodeById(id);
						if (grandchild != null){
							return grandchild;
						}
					}
				}
			}
			return null;
		}
		public function getNodesById(id:String, out:Vector.<LayoutNode>=null):Vector.<LayoutNode>{
			var i:int;
			var child:LayoutNode;
			if (out == null){
				out = new Vector.<LayoutNode>();
			}
			for (i = 0; i < numChildren; i++){
				child = childAt(i);
				if (child != null){
					if(child.id==id){
						out.push(child);
					}
					getNodesById(id, out);
				}
			}
			return out;
		}
		private static function parseNumberSet(str:String):Vector.<int>{
			var sp:Array = str.split(" ");
			if (sp.length == 1){
				var num:int = Number(sp[0]);
				return new <int>[num, num, num, num];
			}else if (sp.length == 2){
				var num1:int = Number(sp[0]);
				var num2:int = Number(sp[1]);
				return new <int>[num1, num2, num1, num2];
			}else if (sp.length == 4){
				return new <int>[Number(sp[0]), Number(sp[1]), Number(sp[2]), Number(sp[3])];
			}else if (sp.length == 3){
				return new <int>[Number(sp[0]), Number(sp[1]), Number(sp[2]), 0];
			}
			return new <int>[0, 0, 0, 0];
		}
	}

}