package com.pcguild.flexocity.parser.node.delimiter.enclosing
{
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  An index opener, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class IndexOpener extends Delimiter
	{
		/**
		 *  Creates a new IndexOpener.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to an IndexOpener object.
		 */
		public function IndexOpener(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.indexOpener, line, column, parent);
		}
	}
}