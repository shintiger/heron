package com.gigateam.heron.util 
{
	/**
	 * ...
	 * @author Tiger
	 */
	public class ActionStack 
	{
		private var _deltaHeight:int = 0;
		private var stackItems:Vector.<IStackItem>;
		public function ActionStack(init:IStackItem=null) 
		{
			stackItems = new Vector.<IStackItem>();
			if(init)
			push(init);
		}
		public function get deltaHeight():int{
			return _deltaHeight;
		}
		/*
		 * Return : 
		 */
		public function push(item:IStackItem, disposePrev:Boolean=true):uint{
			_push(item, disposePrev);
			return height;
		}
		/*
		 * Inner push
		 */
		private function _push(item:IStackItem, disposePrev:Boolean):void{
			var lastHeight:int = height;
			if (top != null){
				top.deactivate(item, disposePrev);
			}
			stackItems.push(item);
			top.deactivate();
			//top.resume();
			
			_deltaHeight = height - lastHeight;
		}
		public function get height():uint{
			return stackItems.length;
		}
		public function pop():IStackItem{
			return _pop();
		}
		private function poppable():Boolean{
			return height > 0 && top.isActivated;
		}
		private function _pop():IStackItem{
			if (!poppable()){
				return null;
			}
			var lastHeight:int = height;
			var popped:IStackItem = stackItems.pop();
			_deltaHeight = height - lastHeight;
			popped.deactivate(top, true);
			if(top!=null){
				//top.resume();
			}
			
			return popped;
		}
		/*
		 * Return : replaced item
		 */
		public function replace(item:IStackItem):IStackItem{
			if (height == 0){
				return null;
			}
			var old:IStackItem = _pop();
			_push(item, false);
			return old;
		}
		public function get top():IStackItem{
			if (stackItems.length == 0){
				return null;
			}
			return stackItems[stackItems.length - 1];
		}
		public function last(num:uint=0):IStackItem{
			if (stackItems.length <= num){
				return null;
			}
			return stackItems[stackItems.length - 1 -num];
		}
	}

}