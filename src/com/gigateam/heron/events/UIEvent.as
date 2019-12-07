package com.gigateam.heron.events 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Tiger
	 */
	public class UIEvent extends Event
	{
		public static const ASSET_PROGRESS:String = "onProgress";
		public static const TRIGGERED:String = "triggered";
		
		public var progressRatio:Number;
		public var data:Object;
		public function UIEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{
			super(type, bubbles, cancelable);
		}
		
	}

}
