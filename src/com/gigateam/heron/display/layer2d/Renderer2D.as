package com.gigateam.heron.display.layer2d 
{
	import com.gigateam.heron.AssetLoader;
	import flash.display.Stage;
	import flash.display.Stage3D;
	import flash.events.Event
	import flash.events.EventDispatcher;
	import flash.geom.Rectangle;
	import starling.animation.IAnimatable;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.Sprite;
	import starling.events.Event;
	import starling.events.ResizeEvent;
	import starling.events.TouchEvent;
	/**
	 * ...
	 * @author Tiger
	 */
	public class Renderer2D extends EventDispatcher implements IAnimatable
	{
		private var _loader:AssetLoader;
		private var _lastTime:Number = 0;
		private var _starling:Starling;
		public function Renderer2D(stage3D:Stage3D, stage:Stage) 
		{
			_starling = new Starling(Sprite, stage, null, stage3D);
			_starling.addEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			_starling.start();
		}
		private function onRootCreated(e:starling.events.Event):void{
			_starling.removeEventListener(starling.events.Event.ROOT_CREATED, onRootCreated);
			//_starling.stage.addEventListener(starling.events.Event.RESIZE, onResize);
			dispatchEvent(new flash.events.Event(flash.events.Event.COMPLETE));
		}
		public function advanceTime(time:Number):void{
			_starling.advanceTime(time-_lastTime);
			_starling.render();
			_lastTime = time;
		}
		public function redraw():void{
			_starling.advanceTime(0);
			_starling.render();
		}
		public function get loader():AssetLoader{
			return _loader;
		}
		public function set loader(loader:AssetLoader):void{
			_loader = loader;
		}
		public function get root():starling.display.DisplayObject{
			return Starling.current.root;
		}
		public function resize(width:int, height:int):void{
			var viewPortRectangle:Rectangle = new Rectangle(0, 0, width, height);
			viewPortRectangle.width = width;
			viewPortRectangle.height = height
			_starling.viewPort = viewPortRectangle;
			if(_starling.stage!=null){
				_starling.stage.stageWidth = width;
				_starling.stage.stageHeight = height;
			}
		}
		public function dispose():void{
			
		}
		public function addOverlay(displayObj:flash.display.DisplayObject):void{
			_starling.nativeOverlay.addChild(displayObj);
		}
		public function removeOverlay(displayObj:flash.display.DisplayObject):void{
			_starling.nativeOverlay.removeChild(displayObj);
		}
	}

}