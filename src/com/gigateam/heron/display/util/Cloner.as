package com.gigateam.heron.display.util 
{
	import starling.display.DisplayObject;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.display.Sprite;
	import starling.text.TextField;
	/**
	 * ...
	 * @author Tiger
	 */
	public class Cloner 
	{
		
		public function Cloner() 
		{
			
		}
		public static function clone(src:DisplayObject):DisplayObject{
			if (src is Sprite){
				return cloneSprite(src as Sprite);
			}else if (src is Image){
				return cloneImage(src as Image);
			}else if (src is TextField){
				return cloneText(src as TextField);
			}
			return null;
		}
		public static function cloneSprite(src:Sprite):Sprite{
			var sprite:Sprite = new Sprite();
			sprite.x = src.x;
			sprite.y = src.y;
			sprite.scale = src.scale;
			return sprite;
		}
		public static function cloneImage(src:Image):Image{
			var image:Image = new Image(src.texture);
			image.scale9Grid = src.scale9Grid;
			image.scale = src.scale;
			image.x = src.x;
			image.y = src.y;
			return image;
		}
		/*public static function cloneMovieClip(src:MovieClip):MovieClip{
			var mc:MovieClip = new MovieClip(src.text
			image.scale9Grid = src.scale9Grid;
			image.scale = src.scale;
			image.x = src.x;
			image.y = src.y;
			return image;
		}*/
		public static function cloneText(src:TextField):TextField{
			var text:TextField = new TextField(src.width, src.height, src.text, src.format);
			text.x = src.x;
			text.y = src.y;
			return text;
		}
	}

}