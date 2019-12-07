package com.gigateam.heron 
{
	import alternativa.engine3d.animation.AnimationClip;
	/**
	 * ...
	 * @author Tiger
	 */
	public class KeyframeLabel 
	{
		public var key:String;
		public var clips:Vector.<AnimationClip>;
		public var duration:Number;
		public function KeyframeLabel() 
		{
			clips = new Vector.<AnimationClip>();
		}
		public function add(clip:AnimationClip):void{
			clips.push(clip);
		}
	}

}