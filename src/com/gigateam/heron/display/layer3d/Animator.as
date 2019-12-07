package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.animation.AnimationNode;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.objects.Skin;
	import starling.animation.IAnimatable;
	/**
	 * ...
	 * @author Tiger
	 */
	public class Animator extends AnimationController implements IAnimatable
	{
		public var current:String = "";
		public var cursor:Number = 0;
		private var currentFrameTimer:Number = 0;
		private var _src:AnimationClip;
		private var _switcher:AnimationSwitcher = new AnimationSwitcher();
		public function Animator(src:AnimationClip) 
		{
			super();
			_src = src;
			root = _switcher;
		}
		override protected function getLocalTimer():Number{
			return currentFrameTimer;
		}
		public function advanceTime (time:Number) : void{
			currentFrameTimer = time;
			update();
		}
		public function slice(key:String, duration:Number = 0):AnimationClip{
			if (duration == 0){
				duration = _src.length - cursor;
			}
			var end:Number = cursor + duration;
			var shifted:AnimationClip = _src.slice(cursor, end);
			cursor = end;
			
			if(key!=""){
				shifted.name = key;
				_switcher.addAnimation(shifted);
			}
			return shifted;
		}
		public function getClipByName(name:String):AnimationClip{
			var i:int;
			for (i = 0; i < _switcher.numAnimations();i++){
				var clip:AnimationClip = _switcher.getAnimationAt(i) as AnimationClip;
				if (clip.name == name){
					return clip;
				}
			}
			return null;
		}
		public function gotoAndPlay(name:String, time:Number = 0):void{
			var clip:AnimationClip = getClipByName(name);
			if (clip.loop && current == name){
				return;
			}
			current = name;
			activate(clip, 0);
			if (!clip.loop){
				clip.normalizedTime = 0;
			}
		}
		public function activate(node:AnimationNode, time:Number = 0):void{
			_switcher.activate(node, time);
		}
		public function get skin():Skin{
			var i:int;
			var max:int = _src.objects.length;
			for (i = 0; i < max; i++){
				if (_src.objects[i] is Skin){
					return _src.objects[i];
				}
			}
			return null;
		}
	}
}