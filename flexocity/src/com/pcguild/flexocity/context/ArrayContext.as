package com.pcguild.flexocity.context
{
	import com.pcguild.flexocity.context.Context;
	
	/**
	 *  Array implementation of a context.
	 * 
	 * @see com.pcguild.flexocity.context.Context
	 */
	public class ArrayContext implements Context
	{
		/**
		 *  Our array.
		 */
		private var _array:Array = new Array();
		
		/**
		 * {@inheritDoc}
		 */
		public function put(key:*, value:*):void
		{
			_array[key] = value;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function getValue(key:*):*
		{
			try {
				return _array[key];
			}
			catch (error:Error) {
				throw new Error("ArrayContext.getValue error");
			}
			
			return null;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function containsKey(key:*):Boolean
		{
			try {
				_array[key];
				return true;
			}
			catch (error:Error) {
				throw new Error("ArrayContext.containsKey error");
			}
			
			return false;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function getKeys():Array
		{
			var keys:Array = new Array;
			
			for (var key:Object in _array) {
				keys.push(key);
			}
			
			return keys;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function remove(key:*):void
		{
			delete _array[key];
		}
	}
}