package com.pcguild.flexocity.parser.node
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.delimiter.DirectiveDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.EscapeDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.ReferenceDelimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  A block of different data, which could be iterated on
	 *  or even ignored.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class Block extends Node
	{
		/**
		 *  Creates a new Block.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new node.
		 * 
		 * @return A reference to a Block object.
		 */
		public function Block(line:int, column:int, parent:Node=null)
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
				if (!(node is Text) && !(node is DirectiveDelimiter)
					&& !(node is ReferenceDelimiter) && !(node is EscapeDelimiter)) {
					throw new ValidationError(this, "Unexpected child found under block: " + node.data);
				}
				
				node.validate();
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function evaluate(context:Context):*
		{
			var output:String = "";
			var index:int = 0;
			
			// If we only have one child, and it's a reference or directive, just pass the evaluate to it.
			// This will make sure we don't lose the object typing.
			if (children.length == 1) {
				if (children.getItemAt(0) is ReferenceDelimiter) {
					return children.getItemAt(0);
				}
				else if (children.getItemAt(0) is DirectiveDelimiter) {
					return DirectiveDelimiter(children.getItemAt(0)).evaluate(context);
				}
			}
			
			// Add the evaluation of each child to the output.
			for (; index < children.length; index++) {
				var node:Node = children.getItemAt(index) as Node;
				
				output += node.evaluate(context);
				output = output.replace("null","");
			}
			
			// If we have a non-special instruction, we need to remove the end of line.
			if (!Instruction(parent).isSpecialInstruction()) {
				var endIndex:int = output.lastIndexOf(ParserSettings.getInstance().delimiterSettings.endOfLine);
				
				if (endIndex != -1) {
					output = output.substr(0, endIndex);
				}
			}
			
			return output;
		}
	}
}