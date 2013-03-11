package com.pcguild.flexocity.parser.node.delimiter
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	import flash.filesystem.FileStream;
	
	/**
	 *  An escape delimiter, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class EscapeDelimiter extends Delimiter
	{
		/**
		 *  Creates a new EscapeDelimiter.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to an EscapeDelimiter object.
		 */
		public function EscapeDelimiter(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.escape, line, column, parent);
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function merge(context:Context, fileStream:FileStream):void
		{
			// We want this to do nothing, because the reference or directive will handle the merge.
		}
	}
}