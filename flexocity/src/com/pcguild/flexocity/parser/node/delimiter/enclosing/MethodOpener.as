package com.pcguild.flexocity.parser.node.delimiter.enclosing
{
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	/**
	 *  A method opener, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class MethodOpener extends Delimiter
	{
		/**
		 *  Creates a new MethodOpener.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a MethodOpener object.
		 */
		public function MethodOpener(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.methodOpener, line, column, parent);
		}
	}
}