package com.pcguild.flexocity.parser.node.delimiter.enclosing
{
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  A formal opener, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class FormalOpener extends Delimiter
	{
		/**
		 *  Creates a new FormalOpener.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a FormalOpener object.
		 */
		public function FormalOpener(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.formalOpener, line, column, parent);
		}
	}
}