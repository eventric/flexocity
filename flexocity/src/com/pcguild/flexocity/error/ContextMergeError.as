package com.pcguild.flexocity.error
{
	import com.pcguild.flexocity.parser.Node;
	
	/**
	 *  An error which occurs when trying to merge context data
	 *  into a template.
	 */
	public class ContextMergeError extends Error
	{
		/**
		 *  Creates a new ContextMergeError.
		 *
		 * @param node The node associated with the error.
		 * @param message A string associated with the error; this parameter 
		 * is optional. 
	     * @param id A reference number to associate with the specific error message.
		 *
		 * @return A reference to a ContextMergeError object.
		 */
		public function ContextMergeError(node:Node, message:String="", id:int=0)
		{
			super("Context Merge Error line " + node.line + ", column " + node.column + ": " + message, id);
		}
	}
}