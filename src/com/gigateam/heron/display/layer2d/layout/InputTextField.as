package com.gigateam.heron.display.layer2d.layout 
{
	import flash.geom.Rectangle;
	import flash.text.TextFieldType;
	import flash.text.TextFormat;
	import starling.display.DisplayObject;
	import starling.text.TextField;
	import flash.text.TextField;
	/**
	 * ...
	 * @author Tiger
	 */
	public class InputTextField{
		private var _obj:DisplayObject;
		public var nativeTextfield:flash.text.TextField;
		public function InputTextField(obj:DisplayObject, tf:flash.text.TextField=null)
		{
			_obj = obj;
			nativeTextfield = tf;
			if (nativeTextfield == null){
				nativeTextfield = new flash.text.TextField();
			}
			nativeTextfield.restrict = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890 -_.@#$%^&*()[]";
			nativeTextfield.maxChars = 9;
			nativeTextfield.width = obj.width;
			nativeTextfield.height = obj.height;
			nativeTextfield.type = TextFieldType.INPUT;
			nativeTextfield.background = false;
			nativeTextfield.textColor = 0;
			var format:TextFormat = new TextFormat(null, 28 , 0xff0000);
			nativeTextfield.defaultTextFormat = format;
			nativeTextfield.text = "Heero Yuy";
			//nativeTextfield.form
		}
		public function updatePosition():void{
			var rect:Rectangle = new Rectangle();
			_obj.getBounds(_obj.stage, rect);
			nativeTextfield.x = rect.left;
			nativeTextfield.y = rect.top;
		}
		public function get text():String{
			return nativeTextfield.text;
		}
		public function set text(t:String):void{
			nativeTextfield.text = t;
		}
		public function dispose():void{
			
		}
	}

}