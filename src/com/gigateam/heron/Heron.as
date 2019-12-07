package com.gigateam.heron 
{
	import com.gigateam.heron.display.AntiAliasLevel;
	import com.gigateam.heron.display.layer2d.Renderer2D;
	import com.gigateam.heron.display.layer2d.ApplicationNode;
	import com.gigateam.heron.display.layer3d.Renderer3D;
	import flash.desktop.NativeApplication;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage3D;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.display3D.Context3D;
	import flash.display3D.Context3DProfile;
	import flash.display3D.Context3DRenderMode;
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.geom.Rectangle;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Tiger
	 */
	public class Heron extends ApplicationNode
	{
		private var _cachedContext3D:Context3D;
		private var _expectedWidth:int = 0;
		private var _expectedHeight:int = 0;
		protected var _renderer2D:Renderer2D;
		protected var _renderer3D:Renderer3D;
		protected var _stage3D:Stage3D;
		public function Heron(resourceDir:File, textureDir:File=null, asset:Array=null, stage3D:Stage3D=null) 
		{
			super(asset);
			_stage3D = stage3D;
			loader = new AssetLoader(resourceDir, textureDir);
			
			if (stage){
				init();
			}else{
				addEventListener(Event.ADDED_TO_STAGE, init);
			}
		}
		public function expected(width:uint, height:uint):void{
			_expectedWidth = width;
			_expectedHeight = height;
		}
		protected function init(e:Event=null):void{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			NativeApplication.nativeApplication.addEventListener(Event.EXITING, exit);
			
			stage.addEventListener(Event.RESIZE, onResize, true);
			if (_stage3D == null){
				_stage3D = stage.stage3Ds[0];
			}
			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			_stage3D.addEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			
			_stage3D.requestContext3D(Context3DRenderMode.AUTO, Context3DProfile.BASELINE);
		}
		protected function onContextCreated(e:Event, customRenderer3D:Renderer3D=null, customRenderer2D:Renderer2D=null):void{
			_stage3D.removeEventListener(Event.CONTEXT3D_CREATE, onContextCreated);
			_cachedContext3D = _stage3D.context3D;
			//_cachedContext3D.enableErrorChecking = true;
			
			_renderer3D = (customRenderer3D == null) ? new Renderer3D(_stage3D, stage) : customRenderer3D;
			_renderer2D = (customRenderer2D == null) ? new Renderer2D(_stage3D, stage) : customRenderer2D;
			
			//_juggler.add(_renderer3D);
			//_juggler.add(_renderer2D);
			
			_renderer2D.loader = loader;
			_renderer3D.loader = loader;
			
			_renderer2D.addEventListener(Event.COMPLETE, onRenderer2DCreated);
		}
		private function onRenderer2DCreated(e:Event):void{
			_renderer2D.removeEventListener(Event.COMPLETE, onRenderer2DCreated);
			
			_object2D = _renderer2D.root;
			_object3D = _renderer3D.root;
			
			addEventListener(Event.ENTER_FRAME, onMainLoop);
			
			dispatchEvent(new Event(Event.INIT));
			construct(this);
			
			onResize();
			_cachedContext3D.configureBackBuffer(stage.stageWidth, stage.stageHeight, AntiAliasLevel.NONE);
		}
		private function onMainLoop(e:Event):void{
			var now:int = getTimer();
			var time:Number = now * 0.001;
			
			advanceTime(time);
		}
		override public function advanceTime(time:Number):void{
			super.advanceTime(time);
			var r:Number = ((stage.color >> 16) & 0xff)/0xff;
			var g:Number = ((stage.color >> 8) & 0xff)/0xff;
			var b:Number = (stage.color & 0xff) / 0xff;
			
			_cachedContext3D.setRenderToBackBuffer();
			//_cachedContext3D.clear(r, g, b);
			_renderer3D.advanceTime(time);
			_renderer2D.advanceTime(time);
			_cachedContext3D.present();
		}
		public function stop():void{
			removeEventListener(Event.ENTER_FRAME, onMainLoop);
		}
		public function play():void{
			if(_heron!=null)
				addEventListener(Event.ENTER_FRAME, onMainLoop);
		}
		public function get renderer2D():Renderer2D{
			return _renderer2D;
		}
		public function get renderer3D():Renderer3D{
			return _renderer3D;
		}
		public function onResize(e:flash.events.Event=null):void{
			//resize(stage.stageWidth, stage.stageHeight);
			var width:int = stage.stageWidth;
			var height:int = stage.stageHeight;
			var scaleFactory:Number = 1;
			if (_expectedWidth > 0 && _expectedHeight > 0){
				var oRatio:Number = _expectedWidth / _expectedHeight;
				var nRatio:Number = width / height;
				
				if (nRatio > oRatio){
					scaleFactory = height / _expectedHeight;
				}else{
					scaleFactory = width / _expectedWidth;
				}
			}
			
			if (_constructed){
				_renderer3D.resize(width, height, scaleFactory);
				_renderer2D.resize(width, height);
			}
			resize(width, height, scaleFactory);
			
		}
		override public function dispose():void{
			super.dispose();
			removeEventListener(Event.ENTER_FRAME, onMainLoop);
			if(stage!=null){
				stage.removeEventListener(Event.RESIZE, onResize, true);
			}
		}
	}

}
