package com.pcguild.flexocity.parser.node
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Text;
	import com.pcguild.flexocity.parser.node.delimiter.DirectiveDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.EscapeDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.ReferenceDelimiter;
	
	import flash.filesystem.FileStream;
	
	/**
	 *  A template, represented as a root node, which gains
	 *  children as the tree gets parsed.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class Template extends Node
	{
		/**
		 *  Creates a new Template.
		 *
		 * @return A reference to a Template object.
		 */
		public function Template()
		{
			super("", 1, 1);
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
					throw new ValidationError(node, "Unexpected child found under template: " + node.data);
				}
				
				node.validate();
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function merge(context:Context, fileStream:FileStream):void
		{
			super.merge(context, fileStream);
			
			trace("Template successfully merged with context.");
		}
	}
}