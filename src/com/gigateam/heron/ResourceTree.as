package com.gigateam.heron 
{
	/**
	 * ...
	 * @author Tiger
	 */
	public class ResourceTree 
	{
		private var _paths:Vector.<String>;
		private var _names:Vector.<String>;
		private var _base:String;
		private var _raw:Object = {};
		public function ResourceTree(base:String) 
		{
			_base = base;
			_paths = new Vector.<String>();
			_names = new Vector.<String>();
		}
		public function add(queue:Array):void{
			var i:int;
			for (i = 0; i < queue.length; i++){
				_paths.push(queue[i].asset);
				_names.push(queue[i].name);
			}
		}
		public function getNamesByDir(dirname:String, dispose:Boolean=true):Vector.<String>{
			var vec:Vector.<String> = new Vector.<String>();
			var i:int;
			var length:int = _paths.length;
			var baselen:int = _base.length + 1;
			for (i = 0; i < length; i++){
				var path:String = _paths[i];
				if (path.substr(baselen).indexOf(dirname) < 0){
					continue;
				}
				vec.push(_names[i]);
				
				if(dispose){
					_names.removeAt(i);
					_paths.removeAt(i);
					length--;
					i--;
				}
			}
			return vec;
		}
		public function purge():void{
			_paths = new Vector.<String>();
			_names = new Vector.<String>();
		}
	}

}