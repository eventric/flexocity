package com.pcguild.flexocity.parser.node.delimiter.enclosing
{
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  A formal closer, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class FormalCloser extends Delimiter
	{
		/**
		 *  Creates a new FormalCloser.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a FormalCloser object.
		 */
		public function FormalCloser(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.formalCloser, line, column, parent);
		}
	}
}