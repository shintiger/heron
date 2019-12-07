package com.gigateam.worker 
{
	import flash.events.Event;
	/**
	 * ...
	 * @author Tiger
	 */
	public class SignalEvent extends Event
	{
		public static const SIGNAL:String = "signalEvent";
		public var signal:WorkerSignal;
		public function SignalEvent(sig:WorkerSignal) 
		{
			super(SIGNAL);
			signal = sig;
		}
		
	}

}