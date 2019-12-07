package com.gigateam.heron.util 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	import flash.text.Font;
	/**
	 * ...
	 * @author Tiger
	 */
	public class FontLoader extends Loader
	{
		private var _loadedClass:Class;
		private var _classString:String = "";
		public function FontLoader() 
		{
			super();
		}
		public function get loadedFont():Class{
			return _loadedClass;
		}
		override public function load(req:URLRequest, loaderContext:LoaderContext = null):void{
			contentLoaderInfo.addEventListener(Event.COMPLETE, fontLoaded);
			super.load(req, loaderContext);
		}
		public function loadFont(url:String, classString:String):URLRequest{
			_classString = classString;
			var request:URLRequest = new URLRequest(url);
			var context:LoaderContext = new LoaderContext(false, new ApplicationDomain( ApplicationDomain.currentDomain ));
			load(request, context);
			
			return request;
		}
		private function fontLoaded(e:Event):void{
			trace("yes");
			contentLoaderInfo.removeEventListener(Event.COMPLETE, fontLoaded);
			
			var font:Class = contentLoaderInfo.applicationDomain.getDefinition(_classString) as Class;
			_loadedClass = font;
			
			dispatchEvent(new Event(Event.COMPLETE));
		}
	}

}