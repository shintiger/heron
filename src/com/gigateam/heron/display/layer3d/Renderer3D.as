package com.gigateam.heron.display.layer3d {
	import alternativa.engine3d.lights.OmniLight;
	import alternativa.engine3d.lights.SpotLight;
	import alternativa.engine3d.loaders.events.TexturesLoaderEvent;
	import alternativa.engine3d.materials.StandardMaterial;
	import com.gigateam.heron.AssetLoader;
	import com.gigateam.heron.display.AntiAliasLevel;
	import eu.nekobit.alternativa3d.core.renderers.NekoRenderer;
	import eu.nekobit.alternativa3d.post.PostEffectRenderer;
	import flash.display3D.textures.TextureBase;
	import flash.events.EventDispatcher;
	import flash.display.Stage3D;
	import flash.events.Event;
	import flash.display.Stage;
	import flash.display3D.Context3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.core.Resource;
	import com.gigateam.world.physics.entity.Body;
	import com.gigateam.world.physics.shape.MovableAABB;
	import com.gigateam.world.physics.shape.AABB;
	import alternativa.engine3d.primitives.Box;
	import alternativa.engine3d.materials.FillMaterial;
	import com.gigateam.world.physics.shape.Vertex;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.View;
	import alternativa.engine3d.lights.AmbientLight;
	import alternativa.engine3d.lights.DirectionalLight;
	import flash.display.Sprite;
	import alternativa.engine3d.controllers.SimpleObjectController;
	import flash.display.StageDisplayState;
	import flash.events.FullScreenEvent;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.geom.Rectangle;
	import flash.geom.Vector3D;
	import flash.geom.Matrix3D;
	import flash.display3D.Context3DRenderMode;
	import starling.animation.IAnimatable;
	
	public class Renderer3D extends EventDispatcher implements IAnimatable{
		private var _rawCameraTransform:Vector.<Vector3D>;
		private var _loader:AssetLoader;
		private var _texturesLoader:TexturesLoader;
		private var rootContainer:Object3D;
		private var contextReady:Boolean = false;
		private var stage:Stage;
		public var cameraMan:Object3D;
		public var camera:Camera3D;
		public var stage3D:Stage3D;
		public var dLight:DirectionalLight
		protected var render:Boolean = true;
		public var renderer:PostEffectRenderer;
		public function Renderer3D(stage3D:Stage3D, stage:Stage) {
			rootContainer = new Object3D();
			var cam:Camera3D = new Camera3D(0.1, 10000);
			camera = cam;
			camera.renderer = new NekoRenderer();
			//camera.debug = true;
			camera.depthAndStencilClear = 127;
			camera.renderPresentsContext = false;
			//camera.renderClearsContext = false;
			//camera.mouseChildren = false;
			//camera.mouseEnabled = false;
			this.stage3D = stage3D;
			this.stage = stage;
			renderer = new PostEffectRenderer(stage3D, camera);
			cameraMan = new Object3D();
			cameraMan.addChild(camera);
			rootContainer.addChild(cameraMan);
			
			//controller = new SimpleObjectController(stage, camera, 1500, 4);
			//controller.setObjectPosXYZ(0, -500, -800);
			
			var ambient:AmbientLight = new AmbientLight(0xffffff);
			ambient.intensity = 0.5;
			ambient.z = 200;
			ambient.y = -200;
			ambient.x = 200;
			//rootContainer.addChild(ambient);
			
			dLight = new DirectionalLight(0xffffff);
			dLight.intensity = 1;
			dLight.z = 200;
			dLight.x = -50;
			dLight.y = -50;
			dLight.lookAt(0, 0, 0);
			
			//rootContainer.mouseChildren = false;
			//rootContainer.mouseEnabled = false;
			//rootContainer.addChild(dLight);
			_texturesLoader = new TexturesLoader(stage3D.context3D);
			//var aabb:AABB = new AABB(new Vertex(0, 0, 0), 100, 100, 100);
			//displayBox(aabb);
			
			_rawCameraTransform = cameraMan.matrix.decompose();
			
			onAdded();
			//addEventListener(Event.ADDED_TO_STAGE, onAdded);
		}
		public function set suspend(b:Boolean):void{
			render = !b;
		}
		public function get suspend():Boolean{
			return !render;
		}
		
		public function reset():void{
			var m:Matrix3D = new Matrix3D();
			m.recompose(_rawCameraTransform);
			camera.matrix = m;	
		}
		public function get loader():AssetLoader{
			return _loader;
		}
		public function set loader(loader:AssetLoader):void{
			_loader = loader;
		}
		public function get root():Object3D{
			return rootContainer;
		}
		protected function onAdded(e:Event=null):void{
			removeEventListener(Event.ADDED_TO_STAGE, onAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			//stage.addEventListener(Event.RESIZE, onResize);
			
			//camera.view = new View(stage.fullScreenWidth, stage.fullScreenHeight, false, stage.color, 1, 4);
			var width:Number;
			var height:Number;
			var bounds:Rectangle;
			if (stage.nativeWindow != null){
				bounds = stage.nativeWindow.bounds;
			}
			if (bounds != null){
				width = bounds.width;
				height = bounds.height;
			}else{
				width = stage.stageWidth;
				height = stage.stageHeight;
			}
			camera.view = new View(width, height, false, stage.color, 1, AntiAliasLevel.MINIMAL);

			camera.view.hideLogo();
			stage.addChild(camera.view);
			stage.addChild(camera.diagram);
			
			contextReady = true;
			uploadAll();
		}
		public function onResize(e:Event = null ):void{
			return;
		}
		public function resize(width:int, height:int, scaleFactory:Number=1):void{
			camera.view.width = width;
			camera.view.height = height;
			
			//rootContainer.scaleX = rootContainer.scaleY = rootContainer.scaleZ = scaleFactory;
		}
		protected function onRemove(e:Event):void{
			removeEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			addEventListener(Event.ADDED_TO_STAGE, onReAdded);
			
			render = false;
		}
		protected function onReAdded(e:Event):void{
			removeEventListener(Event.ADDED_TO_STAGE, onReAdded);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemove);
			
			render = true;
		}
		public function get context3D():Context3D{
			return stage3D.context3D;
		}
		public function uploadResources(container:Object3D, textureBase:TextureBase = null ):ExternalTextureResource{
			var context3D:Context3D = stage3D.context3D;
			var textures:Vector.<ExternalTextureResource> = new Vector.<ExternalTextureResource>();
			var lastExternalResource:ExternalTextureResource;
			for each (var resource:Resource in container.getResources(true)) {
				if (resource.isUploaded){
					continue;
				}
				if (resource is ExternalTextureResource) {
					lastExternalResource = resource as ExternalTextureResource;
					if (textureBase != null){
						lastExternalResource.data = textureBase;
					}else{
						textures.push(resource);
					}
				} else {
					resource.upload(context3D);
				}
			}
			_texturesLoader.addEventListener(TexturesLoaderEvent.COMPLETE, onTexturesComplete);
			_texturesLoader.loadResources(textures);
			
			return lastExternalResource;
		}
		private function onTexturesComplete(e:TexturesLoaderEvent):void{
			//trace("done", e.getTextures().length, e.getBitmapDatas().length);
		}
		
		public function uploadAll():void{
			if(contextReady)
				uploadResources(rootContainer);
		}
		public function advanceTime(time:Number):void{
			if(render){
				//camera.render(stage3D);
				//trace("render");
				renderer.render();
				//rendered = true;
			}else{
				context3D.clear(0, 0, 0, 1, 1, 127);
			}
		}
		public function dispose():void{
		}
	}
}
