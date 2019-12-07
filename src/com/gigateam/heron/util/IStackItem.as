package com.gigateam.heron.util 
{
	
	/**
	 * ...
	 * @author Tiger
	 */
	public interface IStackItem 
	{
		//public function activate():void;
		function deactivate(target:IStackItem=null, dispose:Boolean=false):int;
		function resume(from:IStackItem=null):void;
		function isActivated():Boolean;
	}
}