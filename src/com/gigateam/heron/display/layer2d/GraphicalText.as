package com.gigateam.heron.display.layer2d 
{
	import com.gigateam.heron.AssetLoader;
	import starling.display.Image;
	import starling.display.Sprite;
	import starling.utils.Align;
	/**
	 * ...
	 * @author Tiger
	 */
	public class GraphicalText extends Sprite
	{
		private var _scaleX:Number = 1;
		private var _scaleY:Number = 1;
		private var _fixedWidth:int = 0;
		private var _align:String = Align.LEFT;
		private var _loader:AssetLoader;
		private var _src:Vector.<String>;
		private var _img:Vector.<String>;
		private var _text:String = "";
		public function GraphicalText(loader:AssetLoader, fixWidth:int=0) 
		{
			_fixedWidth = fixWidth;
			_loader = loader;
			_src = new Vector.<String>();
			_img = new Vector.<String>();
		}
		public function get fixedWidth():int{
			return _fixedWidth;
		}
		public function set fixedWidth(w:int):void{
			_fixedWidth = w;
		}
		public function map(str:String, img:String):void{
			_src.push(str);
			_img.push(img);
		}
		public function get align():String{
			return _align;
		}
		public function set align(a:String):void{
			if(Align.isValidHorizontal(a)){
				_align = a;
			}
		}
		public function get text():String{
			return _text;
		}
		public function set text(t:String):void{
			_text = t;
			removeChildren();
			var rx:int = 0;
			var i:int;
			var j:int;
			for (i = 0; i < _text.length; i++){
				j = _src.indexOf(_text.charAt(i));
				if (j < 0){
					continue;
				}
				var img:Image = _loader.getImage(_img[j]);
				img.x = rx;
				//img.scaleX = _scaleX;
				//img.scaleY = _scaleY;
				addChild(img);
				rx += img.width;
			}
			if (_fixedWidth > 0){
				var fixedWidth:Number = _fixedWidth / scaleX;
				var offset:int = 0;
				switch(align){
					case Align.CENTER:
						offset = (fixedWidth - rx) * 0.5;
						break;
					case Align.RIGHT:
						offset = fixedWidth - rx;
						break;
				}
				for (i = 0; i < numChildren; i++){
					getChildAt(i).x += offset;
				}
			}
		}
	}

}