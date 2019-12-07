package com.gigateam.heron 
{
	/**
	 * ...
	 * @author Tiger
	 */
	public class SimpleStateMachine 
	{
		private var _stateIndex:int =-1;
		private var _names:Vector.<String> = new Vector.<String>();
		private var _enableCallback:Vector.<Function> = new Vector.<Function>();
		private var _disableCallback:Vector.<Function> = new Vector.<Function>();
		public function SimpleStateMachine() 
		{
			
		}
		public function add(name:String, onEnable:Function=null, onDisable:Function=null):int{
			if (_names.indexOf(name) >= 0){
				trace("Warnning: name must be unique, ignore");
				return -1;
			}
			
			_names.push(name);
			_enableCallback.push(onEnable);
			_disableCallback.push(onDisable);
			return _names.length - 1;
		}
		public function remove(name:String):int{
			var index:int = _names.indexOf(name);
			if (index < 0){
				return -1;
			}
			if (_stateIndex >= 0){
				if (_stateIndex == index){
					_stateIndex = 0;
				}else{
					var stateName:String = _names[_stateIndex];
					_names.removeAt(index);
					_stateIndex = _names.indexOf(stateName);
				}
			}else{
				_names.removeAt(index);
			}
			
			_enableCallback.removeAt(index);
			_disableCallback.removeAt(index);
			return index;
		}
		public function enable(name:String):int{
			var nextIndex:int = _names.indexOf(name);
			if (nextIndex < 0){
				throw new Error("state notfound");
			}
			if (_stateIndex >= 0 && _disableCallback[_stateIndex]!=null){
				_disableCallback[_stateIndex](_names[nextIndex]);
			}
			if (_enableCallback[nextIndex] != null){
				var lastName:String = "";
				if (_stateIndex >= 0){
					lastName = _names[_stateIndex];
				}
				_enableCallback[nextIndex](lastName);
			}
			_stateIndex = nextIndex;
			
			return nextIndex;
		}
		public function dispose():void{
			_stateIndex = -1;
			_names = null;
			_enableCallback = null;
			_disableCallback = null;
		}
	}

}