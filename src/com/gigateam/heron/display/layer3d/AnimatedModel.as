package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.Parser;
	import alternativa.engine3d.loaders.ParserCollada;
	import flash.utils.ByteArray;
	import starling.animation.IAnimatable;
	/**
	 * ...
	 * @author Tiger
	 */
	public class AnimatedModel extends Object3D implements IAnimatable
	{
		protected var animationController:MultipleAnimationController;
		protected var keyframes:Vector.<KeyframeLabel>;
		protected var _lastTime:int = 0;
		public function AnimatedModel() 
		{
		}
		public function init(parser:Parser, duration:Vector.<int>, keys:Vector.<String>) 
		{
			animationController = new MultipleAnimationController();
			keyframes = new Vector.<KeyframeLabel>();
			slice(parser, duration, keys);
		}
		public static function from3DS(data:ByteArray, durations:Vector.<int>, keys:Vector.<String>, baseURL:String = ""):AnimatedModel{
			var model:AnimatedModel = new AnimatedModel();
			var parser:Parser3DS = new Parser3DS();
			parser.parse(data, baseURL);
			ModelUtil.fromParser(parser, model);
			model.init(parser, durations, keys);
			return model;
		}
		override public function clone():Object3D{
			var model:AnimatedModel = new AnimatedModel();
			return super.clone();
		}
		protected function slice(parser:Parser, durations:Vector.<int>, keys:Vector.<String>):void{
			if (keys.length != durations.length){
				throw new Error("Key and duration length not match");
			}
			var animations:Vector.<AnimationClip> = parser.animations;
			for (var i:int = 0; i < animations.length; i++){
				var from:Number = 0;
				var obj:Object3D = animations[i].objects[0] as Object3D;
				var itemId:uint = animationController.addItem();
				if (obj == null){
					continue;
				}
				var j:int = 0;
				for (j = 0; j < keys.length;j++){
					var duration:int = durations[j];
					var clip:AnimationClip = animations[i].slice(from, duration + from);
					from += duration;
					animationController.addKeyframe(itemId, keys[j], clip);
				}
			}
		}
		public function gotoAndPlay(keylabel:String, offset:Number=0):void{
			animationController.gotoAndPlay(keylabel, offset);
		}
		public function advanceTime():void{
			animationController.update();
		}
	}
}