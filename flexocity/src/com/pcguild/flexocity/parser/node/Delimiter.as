package com.pcguild.flexocity.parser.node
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	
	/**
	 *  A delimiter, which has no children and evaluates to nothing.
	 *  These are meant to be used as markers for how to parse.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class Delimiter extends Node
	{
		/**
		 *  Creates a new Delimiter.
		 * 
		 * @param data The node data.
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new node.
		 * 
		 * @return A reference to a Delimiter object.
		 */
		public function Delimiter(data:String, line:int, column:int, parent:Node=null)
		{
			super(data, line, column, parent);
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function validate():void
		{
			// Normal delimiters have no children.
			if (children != null) {
				throw new ValidationError(this, "Normal delimiters should not have any children.");
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function evaluate(context:Context):*
		{
			// Normal delimiters evaluate to nothing.
			return "";
		}
	}
}