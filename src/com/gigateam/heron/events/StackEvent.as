package com.gigateam.heron.events 
{
	import com.gigateam.heron.display.layer2d.layout.IStackNode;
	import flash.events.Event;
	/**
	 * ...
	 * @author Tiger
	 */
	public class StackEvent extends Event
	{
		public static const STACK_BACK:String = "stackFrameBack";
		public static const STACK_PUSH:String = "stackFramePush";
		public static const STACK_CHANGE:String = "stackFrameChange";
		
		public var from:IStackNode;
		public var to:IStackNode;
		public function StackEvent(type:String, bubbles:Boolean=false, useCapture:Boolean=false) 
		{
			super(type, bubbles, useCapture);
		}
		
	}

}