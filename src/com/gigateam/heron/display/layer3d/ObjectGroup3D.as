package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.Parser;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	import starling.animation.IAnimatable;
	/**
	 * ...
	 * @author Tiger
	 */
	public class ObjectGroup3D extends Object3D implements IAnimatable
	{
		public var material:Material;
		private var animators:Vector.<Animator>;
		private var _hasAnimation:Boolean = false;
		private var _isCollada:Boolean = false;
		private var _parser:Parser;
		private var _collada:ParserCollada;
		public function ObjectGroup3D(obj:Object3D, animations:Vector.<AnimationClip>=null) 
		{
			addChild(obj);
			if (animations){
				var i:int;
				animators = new Vector.<Animator>();
				for (i = 0; i < animations.length; i++){
					animators.push(new Animator(animations[i]));
				}
			}
			scaleX = scaleY = scaleZ = 10;
		}
		private static function hasAnimation(parser:Parser):Boolean{
			if (!(parser is ParserCollada) && !(parser is ParserA3D)){
				return false;
			}
			var collada:ParserCollada = parser as ParserCollada;
			if (collada.animations.length == 0){
				return false;
			}
			return true;
		}
		public static function fromParser(parser:Parser, root:String):ObjectGroup3D{
			var rootObj:Object3D = parser.getObjectByName(root);
			var group:ObjectGroup3D;
			if (hasAnimation(parser)){
				var list:Vector.<AnimationClip> = new Vector.<AnimationClip>();
				var collada:ParserCollada = parser as ParserCollada;
				var cloned:Object3D = rootObj.clone();
				var i:int;
				for (i = 0; i < collada.animations.length; i++){
					list.push(collada.animations[i] as AnimationClip);
				}
				//cloneAnimations(collada, rootObj, list);
				
				group = new ObjectGroup3D(rootObj, list);
			}else{
				group = new ObjectGroup3D(rootObj);
			}
			return group;
		}
		protected static function cloneAnimations(parser:ParserCollada, obj:Object3D, clipList:Vector.<AnimationClip>):void{
			var i:int;
			for (i = 0; i < obj.numChildren; i++){
				var child:Object3D = obj.getChildAt(i);
				var clip:AnimationClip = parser.getAnimationByObject(child);
				if (clip != null){
					trace("clip objects", clip.objects);
					clipList.push(clip.clone());
				}
				cloneAnimations(parser, child, clipList);
			}
		}
		public function setMaterialToAllSurfaces(mat:Material):void{
			material = mat;
			setChildrenMaterial(this, material);
		}
		protected static function setChildrenMaterial(obj:Object3D, mat:Material):void{
			var i:int;
			for (i = 0; i < obj.numChildren; i++){
				var child:Object3D = obj.getChildAt(i);
				if (child is Mesh){
					var mesh:Mesh = child as Mesh;
					mesh.setMaterialToAllSurfaces(mat);
				}else if (child is Object3D){
					setChildrenMaterial(child, mat);
				}else{
					trace("oops!!!");
				}
			}
		}
		public function slice(key:String, duration:Number = 0):void{
			var i:int;
			for (i = 0; i < animators.length; i++){
				animators[i].slice(key, duration);
			}
		}
		public function gotoAndPlay(key:String, offsetTime:Number = 0):void{
			var i:int;
			for (i = 0; i < animators.length; i++){
				animators[i].gotoAndPlay(key, offsetTime);
			}
		}
		protected function validate():Boolean{
			if (!_hasAnimation){
				return false;
			}
			var i:int;
			var len:Number =-1;
			for (i = 0; i < _collada.animations.length; i++){
				var an:AnimationClip = _collada.animations[i] as AnimationClip;
				if (len < 0){
					len = an.length;
				}else if(an.length!=len){
					return false;
				}
			}
			return true;
		}
		public function advanceTime(time:Number):void{
			rotationZ += 0.01;
			var i:int;
			for (i = 0; i < animators.length; i++){
				animators[i].advanceTime(time);
			}
			//update();
		}
		protected function update():void{
			
		}
	}

}