package com.gigateam.heron.display.layer2d.layout 
{
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import starling.animation.Juggler;
	import starling.core.Starling;
	import starling.display.DisplayObject;
	import starling.display.DisplayObjectContainer;
	import starling.events.Touch;
	import starling.events.TouchEvent;
	import starling.events.TouchPhase;
	/**
	 * ...
	 * @author Tiger
	 */
	public class DragScroller 
	{
		public var scaleFactory:Number = 1;
		private static var smoothDivision:int = 2;
		private static var sd_old:Number = (smoothDivision-1)/smoothDivision;
		private static var sd_new:Number = 1/smoothDivision;
		private var lastPos:int = 0;
		private var axis:uint = 0;
		private var _stage:LayoutNode;
		private var focus:LayoutNode;
		private var inertia:Point = new Point();
		private var cursorStartPoint:Point;
		private var objStartPoint:Point = new Point();
		private var _threshold:int;
		private var _juggler:Juggler;
		public function DragScroller(threshold:int = 10, juggler:Juggler=null ) 
		{
			_threshold = threshold;
			if(juggler!=null){
				_juggler = juggler;
			}else{
				_juggler = Starling.juggler;
			}
			
		}
		public function start(stage:LayoutNode):void{
			_stage = stage;
			_stage.obj.addEventListener(TouchEvent.TOUCH, onTouch);
			
			
		}
		private function onTouch(e:TouchEvent):void{
			var t:Touch = e.getTouch(_stage.obj);
			if (t == null){
				return;
			}
			switch(t.phase){
				case TouchPhase.BEGAN:
					cursorStartPoint = new Point(t.globalX, t.globalY);
					//trace(cursorStartPoint);
					if (focus != null){
						focus.stopBounce();
					}
					
					break;
				case TouchPhase.ENDED:
					cursorStartPoint = null;
					if (axis>0){
						//prevent default
						e.stopImmediatePropagation();
						focus.bounceBack(_juggler, (focus.isVecticalScroll?inertia.y:inertia.x)*5);
					}
					axis = 0;
					
					break;
				case TouchPhase.MOVED:
					if (cursorStartPoint == null){
						break;
					}
					var dx:int = t.globalX - cursorStartPoint.x;
					var dy:int = t.globalY - cursorStartPoint.y;
					var rect:Rectangle = new Rectangle();
					//trace(dx, dy);
					if (axis == 0){
						//trace("a");
						var xOver:Boolean = dx > _threshold || dx <-_threshold;
						var yOver:Boolean = dy > _threshold || dy <-_threshold;
						var filter:ScrollFilter = new ScrollFilter(xOver, yOver);
						if (xOver || yOver){
							focus = LayoutBuilder.positionOnNode(_stage, cursorStartPoint.x, cursorStartPoint.y, rect, filter);
							if (focus == null){
								//trace("b");
								break;
							}
							focus.stopBounce();
							objStartPoint.x = focus.content.x;
							objStartPoint.y = focus.content.y;
							if (focus.isVecticalScroll){
								lastPos = focus.content.y;
							}else{
								lastPos = focus.content.x;
							}
							axis = focus.isVecticalScroll ? 1 : 2;
							
							inertia.x = 0;
							inertia.y = 0;
						}
					}else{
						var pos:Number;
						e.stopImmediatePropagation();
						if (!focus.isVecticalScroll){
							dx /= scaleFactory;
							pos = objStartPoint.x + dx;
							var ndx:int = pos - lastPos;
							if (inertia.x == 0){
								inertia.x = ndx;
							}else{
								inertia.x = inertia.x * sd_old + ndx * sd_new;
							}
							//trace("e");
							focus.scrollTo(pos, 0.2);
							lastPos = pos;
						}else{
							dy /= scaleFactory;
							pos = objStartPoint.y + dy;
							var ndy:int = pos - lastPos;
							//trace(ndy);
							if (inertia.y == 0){
								inertia.y = ndy;
							}else{
								inertia.y = inertia.y * sd_old + ndy * sd_new;
							}
							focus.scrollTo(pos, 0.2);
							lastPos = pos;
						}
						
					}
					break;
			}
		}
		public function stop():void{
			if(_stage!=null){
				_stage.obj.removeEventListener(TouchEvent.TOUCH, onTouch);
			}
		}
	}
}