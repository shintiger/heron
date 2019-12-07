package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationController;
	import alternativa.engine3d.animation.AnimationSwitcher;
	/**
	 * ...
	 * @author Tiger
	 */
	public class MultipleAnimationController
	{
		private var controllerClipsKey:Vector.<Vector.<String>>;
		private var controllerClips:Vector.<Vector.<AnimationClip>>;
		private var controllers:Vector.<AnimationController>;
		public function MultipleAnimationController() 
		{
			controllers = new Vector.<AnimationController>();
			controllerClips = new Vector.<Vector.<AnimationClip>>();
			controllerClipsKey = new Vector.<Vector.<String>>();
		}
		//Append a new controller and return the index;
		public function addItem():uint{
			var index:uint = controllers.length;
			var switcher:AnimationSwitcher = new AnimationSwitcher();
			var clips:Vector.<AnimationClip> = new Vector.<AnimationClip>();
			switcher.speed = 1;
			var controller:AnimationController = new AnimationController();
			controller.root = switcher;
			controllerClipsKey.push(new Vector.<String>());
			controllerClips.push(clips);
			controllers.push(controller);
			return index;
		}
		public function addKeyframe(itemId:uint, key:String, clip:AnimationClip):void{
			var controller:AnimationController = controllers[itemId];
			var clips:Vector.<AnimationClip> = controllerClips[itemId];
			var clipsKey:Vector.<String> = controllerClipsKey[itemId];
			var switcher:AnimationSwitcher = controller.root as AnimationSwitcher;
			switcher.addAnimation(clip);
			clipsKey.push(key);
			clips.push(clip);
		}
		public function gotoAndPlay(key:String, offset:Number):void{
			var i:int = 0;
			for (i = 0; i < controllers.length; i++){
				var switcher:AnimationSwitcher = controllers[i].root as AnimationSwitcher;
				switcher.activate(getClipByKey(key, controllerClipsKey[i], controllerClips[i]), offset);
			}
		}
		private function getClipByKey(key:String, keyList:Vector.<String>, clipList:Vector.<AnimationClip>):AnimationClip{
			var i:int = 0;
			for (i = 0; i < keyList.length; i++){
				if (keyList[i] == key){
					return clipList[i];
				}
			}
			return null;
		}
		public function update():void{
			var i:int = 0;
			for (i = 0; i < controllers.length; i++){
				controllers[i].update();
				//controllers[i].update();
			}
		}
	}

}