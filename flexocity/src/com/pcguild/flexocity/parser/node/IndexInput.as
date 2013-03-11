package com.pcguild.flexocity.parser.node
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.delimiter.DirectiveDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.EscapeDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.ReferenceDelimiter;
	
	/**
	 *  The provided value for the indexing.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class IndexInput extends Node
	{
		/**
		 *  Creates a new IndexInput.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new node.
		 * 
		 * @return A reference to a IndexInput object.
		 */
		public function IndexInput(line:int, column:int, parent:Node=null)
		{
			super("", line, column, parent);
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function validate():void
		{
			for each (var node:Node in children) {
				// If it's not an expected child, throw error.
				if (!(node is Text) && !(node is DirectiveDelimiter) && !(node is ReferenceDelimiter)
					&& !(node is EscapeDelimiter)) {
					throw new ValidationError(this, "Unexpected child found under index input: " + node.data);
				}
				
				node.validate();
			}
		}
	}
}