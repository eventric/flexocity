package com.pcguild.flexocity.parser.node.delimiter.logic
{
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  A greater than equal delimiter, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class GreaterThanEqualDelimiter extends Delimiter
	{
		/**
		 *  Creates a new GreaterThanEqualDelimiter.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a GreaterThanEqualDelimiter object.
		 */
		public function GreaterThanEqualDelimiter(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.greaterThanEquals, line, column, parent);
		}
	}
}