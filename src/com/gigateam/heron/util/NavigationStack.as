package com.gigateam.heron.util 
{
	/**
	 * ...
	 * @author Tiger
	 */
	public class NavigationStack extends ActionStack
	{
		private static var _instance:NavigationStack;
		public function NavigationStack(init:IStackItem=null) 
		{
			super(init);
		}
		public static function navigationStack():NavigationStack{
			if (_instance == null){
				_instance = new NavigationStack();
			}
			return _instance;
		}
	}

}