package com.gigateam.heron.display.util 
{
	import flash.utils.Timer;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Tiger
	 */
	public class ProfileUtil 
	{
		private static var lastTimer:int = -1;
		public function ProfileUtil() 
		{
			
		}
		public static function startTimer():void{
			lastTimer = getTimer();
		}
		public static function stopTimer():int{
			if (lastTimer < 0){
				return lastTimer;
			}
			var dis:int = getTimer() - lastTimer;
			lastTimer =-1;
			return dis;
		}
	}

}