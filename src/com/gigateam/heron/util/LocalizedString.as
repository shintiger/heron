package com.gigateam.heron.util 
{
	import com.gigateam.heron.AssetLoader;
	import com.gigateam.heron.events.StackEvent;
	/**
	 * ...
	 * @author Tiger
	 */
	public class LocalizedString 
	{
		private var _keys:Vector.<String>;
		private var _str:Vector.<String>;
		public function LocalizedString(xml:XML) 
		{
			_keys = new Vector.<String>();
			_str = new Vector.<String>();
			var xmllist:XMLList = xml.children();
			for each (var node:XML in xmllist)
			{
				_keys.push(node.@name);
				_str.push(node.toString());
			}
		}
		public function getString(name:String, params:Vector.<String>=null):String{
			var i:int = _keys.indexOf(name);
			if (i < 0){
				return "";
			}
			if(params==null){
				return _str[i];
			}
			return getGeneric(_str[i], params);
		}
		public static function getGeneric(str:String, params:Vector.<String>):String{
			var j:int = 0;
			var k:int = 0;
			var find:String = "{[]}";
			while (k<params.length){
				j = str.indexOf(find, j);
				if (j < 0){
					break;
				}
				str = str.replace(find, params[k]);
				j++;
				k++;
			}
			return str;
		}
		public function dispose():void{
			
		}
	}

}