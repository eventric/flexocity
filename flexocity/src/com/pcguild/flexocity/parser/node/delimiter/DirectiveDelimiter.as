package com.pcguild.flexocity.parser.node.delimiter
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.node.Instruction;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.FormalCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.FormalOpener;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	import flash.filesystem.FileStream;
	
	/**
	 *  A directive delimiter, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class DirectiveDelimiter extends Delimiter
	{
		/**
		 *  The instruction for this directive.
		 */
		private var _instruction:Instruction;
		
		/**
		 *  Creates a new DirectiveDelimiter.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a DirectiveDelimiter object.
		 */
		public function DirectiveDelimiter(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.directive, line, column, parent);
		}
		
		/**
		 *  Returns this directive's instruction.
		 *  
		 * @return The instruction.
		 */
		public function get instruction():Instruction
		{
			return _instruction;
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function validate():void
		{
			var openerFound:Boolean = ParserSettings.getInstance().delimiterSettings.shorthandInstructionsDisabled;
			var index:int = 0;
			var previousChild:Node = null;
			
			// Check for formal opener.
			if ((children.length > 1) && (children.getItemAt(0) is FormalOpener)) {
				openerFound = true;
				index++;
			}
			
			// Check for instruction.
			if (children.getItemAt(index) is Instruction) {
				_instruction = Instruction(children.getItemAt(index));
				_instruction.validate();
			}
			else {
				throw new ValidationError(this, "Directive structure is invalid.");
			}
			
			// If we had an opener, there should be a closer.
			if (openerFound && !(children.getItemAt(children.length - 1) is FormalCloser)) {
				throw new ValidationError(this, "Matching formal closer not found for opener.");
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function evaluate(context:Context):*
		{
			var output:String = "";
			var escapeCount:int = 0;
			var index:int;
			
			// Find this object in the parent's children.
			for (index = 0; index < parent.children.length; index++) {
				if (parent.children.getItemAt(index) == this) {
					break;
				}
			}
			
			// Start with the previous child, and count the escapes.
			for (--index; index > 0; index--) {
				if (parent.children.getItemAt(index) is EscapeDelimiter) {
					escapeCount++;
				}
				else {
					break;
				}
			}
			
			// We need to write out just the escape pairs, i.e. escape == \, then \\ -> \.
			while (escapeCount > 1) {
				output += ParserSettings.getInstance().delimiterSettings.escape;
				escapeCount -= 2;
			}
			
			// If we had an even number of escapes, then the instruction was not escaped and can be evaluated.
			if ((escapeCount % 2) == 0) {
				if (output != "") {
					return output + _instruction.evaluate(context);
				}
				else {
					return _instruction.evaluate(context);
				}
			}
			
			return null;
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function merge(context:Context, fileStream:FileStream):void
		{
			var output:String = "";
			var escapeCount:int = 0;
			var index:int;
			
			// Find this object in the parent's children.
			for (index = 0; index < parent.children.length; index++) {
				if (parent.children.getItemAt(index) == this) {
					break;
				}
			}
			
			// Start with the previous child, and count the escapes.
			for (--index; index > 0; index--) {
				if (parent.children.getItemAt(index) is EscapeDelimiter) {
					escapeCount++;
				}
				else {
					break;
				}
			}
			
			// We need to write out just the escape pairs, i.e. escape == \, then \\ -> \.
			while (escapeCount > 1) {
				output += ParserSettings.getInstance().delimiterSettings.escape;
				escapeCount -= 2;
			}
			
			// If we had an even number of escapes, then the instruction was not escaped and can be evaluated.
			if ((escapeCount % 2) == 0) {
				output += _instruction.evaluate(context);
				fileStream.writeUTFBytes(output);
				return;
			}
			
			fileStream.writeUTFBytes(output);
			
			// Let the super deal with the rest.
			super.merge(context, fileStream);
		}
	}
}