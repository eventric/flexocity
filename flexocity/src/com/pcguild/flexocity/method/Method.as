package com.pcguild.flexocity.method
{
	/**
	 *  An object used to represent a method call.
	 */
	public class Method
	{
		private var _method:Function;
		private var _args:Array;
		
		/**
		 *  Creates a new Method.
		 *
		 * @param method The function of the method call. 
	     * @param args The arguments of the method call, if any.
		 *
		 * @return A reference to a Method object.
		 */
		public function Method(method:Function, args:Array=null)
		{
			_method = method;
			_args = args;
		}
		
		/**
		 *  Returns the method function.
		 *  
		 * @return The function.
		 */
		public function get method():Function
		{
			return _method;
		}
		
		/**
		 *  Returns the method arguments.
		 *  
		 * @return The arguments.
		 */
		public function get args():Array
		{
			return _args;
		}
	}
}