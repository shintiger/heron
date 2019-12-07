package com.gigateam.heron.events 
{
	import starling.events.Event;
	/**
	 * ...
	 * @author Tiger
	 */
	public class WheelEvent extends Event
	{
		public var delta:int;
		public static const MOUSE_WHEEL:String = "mouseWheel";
		public function WheelEvent(type:String, bubbles:Boolean = false, data:Object = null) 
		{
			super(type, bubbles, data);
		}
	}

}