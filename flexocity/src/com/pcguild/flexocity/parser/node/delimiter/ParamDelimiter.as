package com.pcguild.flexocity.parser.node.delimiter
{
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  A param delimiter, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class ParamDelimiter extends Delimiter
	{
		/**
		 *  Creates a new ParamDelimiter.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a ParamDelimiter object.
		 */
		public function ParamDelimiter(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.param, line, column, parent);
		}
	}
}