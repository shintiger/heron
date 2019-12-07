package com.gigateam.heron.display.util {
	import flash.geom.Rectangle;
	import starling.display.DisplayObject;
	
	public class Alignment {
		private static const TOP:int = 1;
		private static const MIDDLE:int = 2;
		private static const BOTTOM:int = 3;
		
		private static const LEFT:int = 1<<2;
		private static const CENTER:int = 2<<2;
		private static const RIGHT:int = 3<<2;
		
		public static const TOP_LEFT:int = TOP | LEFT;
		public static const TOP_CENTER:int = TOP | CENTER;
		public static const TOP_RIGHT:int = TOP | RIGHT;
		
		public static const MIDDLE_LEFT:int = MIDDLE | LEFT;
		public static const MIDDLE_CENTER:int = MIDDLE | CENTER;
		public static const MIDDLE_RIGHT:int = MIDDLE | RIGHT;
		
		public static const BOTTOM_LEFT:int = BOTTOM | LEFT;
		public static const BOTTOM_CENTER:int = BOTTOM | CENTER;
		public static const BOTTOM_RIGHT:int = BOTTOM | RIGHT;
		
		public function Alignment() {
			// constructor code
		}
		public static function align(target:DisplayObject, alignType:int, bounding:Rectangle, inheriting:Boolean=true, offsetX:int=0, offsetY:int=0):void{
			var vAlign:int = alignType & 3;
			var hAlign:int = (alignType>>2) & 3;
			var targetBounds:Rectangle;
			//bounding = target.parent.getBounds(target.parent.parent);
			targetBounds = target.getBounds(target.parent);
			
			target.x = actualAlign(hAlign, targetBounds.x, targetBounds.left, targetBounds.width, bounding.x, bounding.left, bounding.width, offsetX, inheriting);
			target.y = actualAlign(vAlign, targetBounds.y, targetBounds.top, targetBounds.height, bounding.y, bounding.top, bounding.height, offsetY, inheriting);
		}
		private static function actualAlign(alignType:int, targetCoor:int, targetMin:int, targetLength:int, boundingCoor:int, boundingMin:int, boundingLength:int, offset:int, inheriting:Boolean=true):int{
			var targetOffset:int = targetCoor-targetMin;
			var calculated:int = relativeAlign(alignType, boundingLength, targetLength, offset);
			if(inheriting){
				var boundingOffset:int = boundingCoor-boundingMin;
				return targetOffset-boundingOffset+calculated;
			}
			return boundingCoor+calculated-targetOffset;
		}
		private static function relativeAlign(alignType:int, boundingLength:int, targetLength:int, offset:int):int{
			if((targetLength+offset)>boundingLength){
				//return 0;
			}
			switch(alignType){
				case 1:
					return offset;
					break;
				case 2:
					return (boundingLength-targetLength)*0.5+offset;
					break;
				case 3:
					return boundingLength-targetLength-offset;
					break;
				default:
					return 0;
			}
		}
	}
	
}
