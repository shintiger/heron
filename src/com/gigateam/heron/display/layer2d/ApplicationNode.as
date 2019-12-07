package com.gigateam.heron.display.layer2d 
{
	import alternativa.engine3d.core.Object3D;
	import com.gigateam.heron.AssetLoader;
	import com.gigateam.heron.Heron;
	import com.gigateam.heron.display.layer2d.layout.ITextFilter;
	import com.gigateam.heron.display.layer2d.layout.LayoutBuilder;
	import com.gigateam.heron.display.layer3d.Renderer3D;
	import com.gigateam.heron.events.UIEvent;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.utils.Timer;
	import starling.animation.Juggler;
	import starling.events.Event;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	/**
	 * ...
	 * @author Tiger
	 */
	public class ApplicationNode extends flash.display.Sprite
	{
		protected var _lastTime:Number = 0;
		protected var _juggler:Juggler = new Juggler();
		protected var _object2D:starling.display.DisplayObject;
		protected var _object3D:Object3D;
		protected var _heron:Heron;
		protected var _assets:Array;
		protected var _loader:AssetLoader;
		protected var _builder:LayoutBuilder;
		protected var _constructed:Boolean = false;
		public function ApplicationNode(assets:Array=null) 
		{
			if (!assets){
				assets = [];
			}
			_assets = assets;
			super.visible = false;
			addEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToNativeStage);
		}
		protected function onAddedToNativeStage(e:flash.events.Event):void{
			removeEventListener(flash.events.Event.ADDED_TO_STAGE, onAddedToNativeStage);
		}
		protected function construct(h:Heron):void{
			if (_constructed){
				return;
			}
			_constructed = true;
			_heron = h;
			_loader = h.loader;
			
			var i:int;
			for (i = 0; i < _assets.length; i++){
				trace(i, _assets[i]);
				_loader.enqueueGroup(_assets[i]);
			}
			
			var enqueuedAssets:int = _loader.numQueuedAssets;
			trace(enqueuedAssets);
			_loader.loadQueue(onAssetProgress);
			
			_heron = h;
			for (i = 0; i < numChildren; i++){
				var child:flash.display.DisplayObject = getChildAt(i);
				if (child is ApplicationNode){
					(child as ApplicationNode).construct(h);
				}
			}
			if (enqueuedAssets == 0){
				var t:Timer = new Timer(1);
				t.addEventListener(TimerEvent.TIMER, onDelayedTimer);
				t.start();
			}
		}
		private function onDelayedTimer(e:TimerEvent):void{
			var timer:Timer = e.target as Timer;
			timer.removeEventListener(TimerEvent.TIMER, onDelayedTimer);
			timer.stop();
			
			onAssetProgress(1);
		}
		protected function onAssetProgress(ratio:Number):void{
			var evt:UIEvent;
			evt = new UIEvent(UIEvent.ASSET_PROGRESS);
			evt.progressRatio = ratio;
			dispatchEvent(evt);
			return;
		}
		protected function destruct():void{
			var i:int;
			for (i = 0; i < _assets.length; i++){
				_loader.removeGroup(_assets[i]);
			}
			_constructed = false;
			
			_loader = null;
			_heron = null;
			
			for (i = 0; i < numChildren; i++){
				var child:flash.display.DisplayObject = getChildAt(i);
				if (child is ApplicationNode){
					(child as ApplicationNode).destruct();
				}
			}
		}
		override public function addChild(child:flash.display.DisplayObject):flash.display.DisplayObject{
			if (_heron!=null && (child is ApplicationNode)){
				(child as ApplicationNode).construct(_heron);
			}
			return super.addChild(child);
		}
		override public function removeChild(child:flash.display.DisplayObject):flash.display.DisplayObject{
			var returnedChild:flash.display.DisplayObject = super.removeChild(child);
			if (_heron!=null && (returnedChild is ApplicationNode)){
				(returnedChild as ApplicationNode).destruct();
			}
			return returnedChild;
		}
		public function get object2D():starling.display.DisplayObject{
			return _object2D;
		}
		public function set object2D(obj2D:starling.display.DisplayObject):void{
			if (_object2D != null){
				if (_object2D.parent != null && _object2D.parent.contains(_object2D)){
					_object2D.parent.removeChild(_object2D);
					//_object2D.dispose();
				}
			}
			_object2D = obj2D;
			if (parent != null && (parent is ApplicationNode) && (parent as ApplicationNode).object2D!=null && ((parent as ApplicationNode).object2D is DisplayObjectContainer)){
				(((parent as ApplicationNode).object2D) as DisplayObjectContainer).addChild(_object2D);
			}
			heron.onResize();
		}
		public function get object3D():Object3D{
			return _object3D;
		}
		public function set object3D(obj3D:Object3D):void{
			if (_object3D != null){
				if (_object3D.parent != null && _object3D.parent.contains(_object3D)){
					_object3D.parent.removeChild(_object3D);
				}
			}
			_object3D = obj3D;
			if (parent != null && (parent is ApplicationNode) && (parent as ApplicationNode).object3D != null){
				(parent as ApplicationNode).object3D.addChild(_object3D);
			}
		}
		public function get heron():Heron{
			return _heron;
		}
		public function set loader(loader:AssetLoader):void{
			_loader = loader;
		}
		public function get loader():AssetLoader{
			return _loader;
		}
		public function exit(e:flash.events.Event=null):void{
			var i:int;
			var node:ApplicationNode;
			for (i = 0; i < numChildren; i++){
				node = getChildAt(i) as ApplicationNode;
				if (node == null){
					continue;
				}
				node.exit(e);
			}
		}
		public function build(filename:String, filter:ITextFilter=null):starling.display.Sprite{
			if (_builder != null){
				//_builder.dispose();
			}
			_builder = new LayoutBuilder(loader.getXml(filename), loader, _juggler);
			_builder.textFilter = filter;
			var sprite:starling.display.Sprite = _builder.build();
			return sprite;
		}
		public function get builder():LayoutBuilder{
			return _builder;
		}
		public function set builder(b:LayoutBuilder):void{
			_builder = b;
		}
		public function advanceTime(time:Number):void{
			_juggler.advanceTime(time-_lastTime);
			_lastTime = time;
			var i:int;
			var num:Number = numChildren;
			for (i = 0; i < numChildren; i++){
				if (getChildAt(i) is ApplicationNode){
					var node:ApplicationNode = getChildAt(i) as ApplicationNode;
					node.advanceTime(time);
				}
			}
		}
		protected function resize(width:int, height:int, scaleFactory:Number):void{
			var scaleFactor:Number = 1;
			if (_builder != null){
				scaleFactor = _builder.resize(width, height, scaleFactory);
			}
			
			var i:int;
			var node:ApplicationNode;
			for (i = 0; i < numChildren; i++){
				node = getChildAt(i) as ApplicationNode;
				if (node == null){
					continue;
				}
				node.resize(width, height, scaleFactory);
			}
		}
		public function dispose():void{
		}
	}
}