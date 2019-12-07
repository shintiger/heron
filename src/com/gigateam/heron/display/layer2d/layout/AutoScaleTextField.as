package com.gigateam.heron.display.layer2d.layout 
{
	import flash.geom.Rectangle;
	import starling.text.TextField;
	import starling.text.TextFormat;
	import starling.text.TextOptions;
	/**
	 * ...
	 * @author Tiger
	 */
	public class AutoScaleTextField extends TextField
	{
		
		public function AutoScaleTextField(width:int, height:int, text:String="", format:TextFormat=null, options:TextOptions=null) 
		{
			super(width, height, text, format, options);
		}
		override public function set text(txt:String):void{
			super.text = txt;
			var bounds:Rectangle = textBounds;
			width = bounds.width;
			height = bounds.height;
		}
	}

}