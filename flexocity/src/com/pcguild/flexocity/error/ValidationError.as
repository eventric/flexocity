package com.pcguild.flexocity.error
{
	import com.pcguild.flexocity.parser.Node;
	
	/**
	 *  An error which occurs when trying to validate a template.
	 */
	public class ValidationError extends Error
	{
		/**
		 *  Creates a new ValidationError.
		 *
		 * @param node The node associated with the error.
		 * @param message A string associated with the error; this parameter 
		 * is optional. 
	     * @param id A reference number to associate with the specific error message.
		 *
		 * @return A reference to a ValidationError object.
		 */
		public function ValidationError(node:Node, message:String="", id:int=0)
		{
			super("Validaition Error line " + node.line + ", column " + node.column + ": " + message, id);
		}
		
	}
}