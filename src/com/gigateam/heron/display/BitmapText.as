package com.gigateam.heron.display 
{
	import flash.display.BitmapData;
	import flash.display.BlendMode;
	import flash.geom.Matrix;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	/**
	 * ...
	 * @author Tiger
	 */
	public class BitmapText 
	{
		public var textfield:TextField;
		private var _color:uint = 0xffffff;
		private var _size:uint = 50;
		private var format:TextFormat;
		public var width:int = 512;
		public var height:int = 128;
		public function BitmapText() 
		{
			textfield = new TextField();
			textfield.textColor = color;
			format = new TextFormat();
			format.align = TextFormatAlign.CENTER;
			format.size = size;
			format.color = color;
			textfield.setTextFormat(format);
			textfield.defaultTextFormat = format;
		}
		public function set size(s:uint):void{
			_size = s;
			format.size = _size;
			textfield.defaultTextFormat = format;
		}
		public function get size():uint{
			return _size;
		}
		public function set color(c:uint):void{
			_color = c;
			format.color = _color;
			textfield.defaultTextFormat = format;
		}
		public function get color():uint{
			return _color;
		}
		public function draw(text:String):BitmapData{
			textfield.text = text;
			var data:BitmapData = new BitmapData(width, height, true, 0x00000000);
			textfield.width = width;
			textfield.height = height;
			textfield.x = (width - textfield.width) * 0.5;
			textfield.y = (height - textfield.height) * 0.5;
			var m : Matrix = new Matrix();
			m.translate(textfield.x, textfield.y);
			data.draw(textfield, m);
			return data;
		}
	}

}