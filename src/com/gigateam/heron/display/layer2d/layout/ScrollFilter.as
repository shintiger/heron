package com.gigateam.heron.display.layer2d.layout 
{
	/**
	 * ...
	 * @author Tiger
	 */
	public class ScrollFilter implements ICapturingFilter{
		public var xScrolling:Boolean = false;
		public var yScrolling:Boolean = false;
		private var _isVertical:Boolean;
		public function ScrollFilter(xScrolled:Boolean, yScrolled:Boolean) 
		{
			xScrolling = xScrolled;
			yScrolling = yScrolled;
		}
		public function suitable(child:LayoutNode):Boolean{
			if (!child.scrollable){
				return false;
			}else if (child.isVecticalScroll && yScrolling){
				return true;
			}else if (!child.isVecticalScroll && xScrolling){
				return true;
			}
			return false;
		}
	}

}