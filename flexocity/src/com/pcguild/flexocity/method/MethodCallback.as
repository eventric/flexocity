package com.pcguild.flexocity.method
{
	import com.pcguild.flexocity.context.Context;
	
	/**
	 *  An object used to represent a method callback.
	 */
	public class MethodCallback
	{
		/**
		 *  Error code for no error.
		 */
		public static const NO_ERROR:int = -1;
		
		/**
		 *  Error code for default error (as defined by the Error constructor).
		 */
		public static const DEFAULT_ERROR:int = 0;
		
		/**
		 *  Error code for template error.
		 */
		public static const TEMPLATE_ERROR:int = 1;
		
		private var _method:Function;
		private var _context:Context;
		
		/**
		 *  The error code for this method callback. If an error occurred in
		 *  the method call before this callback is used, then the method
		 *  associated with this callback will be able to see what happened.
		 */
		public var errorCode:int = NO_ERROR;
		
		/**
		 *  Creates a new MethodCallback.
		 *
		 * @param method The function of the method callback. The method
		 * signature for this should be name(callback:MethodCallback).
	     * @param context The context to be used in the method callback. This
	     * will contain whatever variables which should be used by the
	     * callback.
		 *
		 * @return A reference to a MethodCallback object.
		 */
		public function MethodCallback(method:Function, context:Context=null)
		{
			_method = method;
			_context = context;
		}
		
		/**
		 *  Returns the callback function.
		 *  
		 * @returns The function.
		 */
		public function get method():Function
		{
			return _method;
		}
		
		/**
		 *  Returns the callback context.
		 *  
		 * @return The context.
		 */
		public function get context():Context
		{
			return _context;
		}
		
		/**
		 *  Whether there was an error before the callback.
		 *  
		 * @return Whether an error had occurred.
		 */
		public function hasError():Boolean
		{
			return errorCode != NO_ERROR
		}
	}
}