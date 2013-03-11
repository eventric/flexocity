package com.pcguild.flexocity.parser.node
{
	import com.adobe.utils.StringUtil;
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.delimiter.DirectiveDelimiter;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	import flash.filesystem.FileStream;
	
	/**
	 *  A text node.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class Text extends Node
	{
		/**
		 *  Creates a new Text.
		 * 
		 * @param data The node data.
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new node.
		 * 
		 * @return A reference to a Text object.
		 */
		public function Text(data:String, line:int, column:int, parent:Node=null)
		{
			super(data, line, column, parent);
		}
		
		/**
		 *  Returns whether this text is just whitespace.
		 *  
		 * @return Whether this is whitespace.
		 */
		public function get isWhitespace():Boolean
		{
			return StringUtil.trim(data) == "";
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function evaluate(context:Context):*
		{
			var value:String = data
			var nextIndex:int = parent.children.getItemIndex(this) + 1;
			
			// We want to remove end of lines from any text that comes before a directive.
			if ((nextIndex < parent.children.length) && (parent.children.getItemAt(nextIndex) is DirectiveDelimiter)) {
				var endIndex:int = value.lastIndexOf(ParserSettings.getInstance().delimiterSettings.endOfLine);
				value = value.substr(0, endIndex);
			}
			
			return value;
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function merge(context:Context, fileStream:FileStream):void
		{
			fileStream.writeUTFBytes(evaluate(context));
		}
	}
}