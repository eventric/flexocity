package com.pcguild.flexocity.parser.node.delimiter.logic
{
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  A less than equal delimiter, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class LessThanEqualDelimiter extends Delimiter
	{
		/**
		 *  Creates a new LessThanEqualDelimiter.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a LessThanEqualDelimiter object.
		 */
		public function LessThanEqualDelimiter(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.lessThanEquals, line, column, parent);
		}
	}
}