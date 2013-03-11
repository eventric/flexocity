package com.pcguild.flexocity.parser.node.delimiter
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ContextMergeError;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.Delimiter;
	import com.pcguild.flexocity.parser.node.Identifier;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.FormalCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.FormalOpener;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	
	import flash.filesystem.FileStream;
	
	/**
	 *  A reference delimiter, represented as a delimiter.
	 *  
	 * @see com.pcguild.flexocity.parser.node.Delimiter
	 */
	public class ReferenceDelimiter extends Delimiter
	{
		/**
		 *  Creates a new ReferenceDelimiter.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new delimiter.
		 * 
		 * @return A reference to a ReferenceDelimiter object.
		 */
		public function ReferenceDelimiter(line:int, column:int, parent:Node=null)
		{
			super(ParserSettings.getInstance().delimiterSettings.reference, line, column, parent);
		}
		
		/**
		 *  This sets the value into the context at the location
		 *  this reference points to.
		 *  
		 * @param value The value to be set for this reference.
		 * @param context The context we're working in.
		 */
		public function setValue(value:*, context:Context):void
		{
			var currentObject:Object;
			var index:int = 0;
			var enclosingOffset:int = 0;
			var disabledShorthandAdjustment:int = 0;
			var identifier:Identifier;
			
			// If the first child is an opener, skip it.
			if (children.getItemAt(0) is FormalOpener) {
				index++;
				enclosingOffset++;
			}
			else if (ParserSettings.getInstance().delimiterSettings.shorthandIdentifiersDisabled) {
				enclosingOffset++;
				disabledShorthandAdjustment++;
			}
			
			identifier = children.getItemAt(index) as Identifier;
			
			// If there is only one identifier, set the value in the context.
			if ((2 * enclosingOffset - disabledShorthandAdjustment) == (children.length - 1)) {
				context.put(identifier.data, value);
				return;
			}
			// We need to get the corresponding object, or create one and add it if there isn't one.
			else {
				if (context.containsKey(identifier.data)) {
					currentObject = context.getValue(identifier.data);
				}
				else {
					currentObject = new Object();
					context.put(identifier.data, currentObject);
				}
				
				index += 2;
			}
			
			// Iterate through the chain, either getting the next object or creating a new one if not found.
			// We don't want to handle the last identifier here.
			for (; index < (children.length - enclosingOffset - 1); index += 2) {
				identifier = children.getItemAt(index) as Identifier;
				
				try {
					currentObject = currentObject[identifier.data];
				}
				catch (error:Error) {
					currentObject[identifier.data] = new Object();
					currentObject = currentObject[identifier.data];
				}
			}
			
			identifier = children.getItemAt(index) as Identifier;
			
			currentObject[identifier.data] = value;
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function validate():void
		{
			var openerFound:Boolean = ParserSettings.getInstance().delimiterSettings.shorthandIdentifiersDisabled;
			var index:int = 0;
			var previousChild:Node = null;
			
			// Check for formal opener.
			if ((children.length > 1) && (children.getItemAt(0) is FormalOpener)) {
				openerFound = true;
				index++;
			}
			
			// Loop through the rest except for the last one if there is an opener.
			for (; index < (openerFound ? (children.length - 1) : children.length); index++) {
				// If identifier and either first or succeeding a sequence delimiter, then validate.
				if (((previousChild == null) || (previousChild is SequenceDelimiter)) && (children[index] is Identifier)) {
					previousChild = children[index] as Identifier;
					previousChild.validate();
				}
				// If sequence delimiter and succeeding an identifier, then continue.
				else if ((previousChild is Identifier) && (children[index] is SequenceDelimiter)) {
					previousChild = children[index] as SequenceDelimiter;
				}
				else {
					throw new ValidationError(this, "Reference structure is invalid.");
				}
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
			var returnObject:Object;
			var index:int = 0;
			var identifier:Identifier;
			
			// If the first child is an opener, skip it.
			if (children.getItemAt(0) is FormalOpener) {
				index++;
			}
			
			// Clear out the previous.
			context.remove(Identifier.PREVIOUS_IDENTIFIER_OBJECT);
			
			try {
				while ((index < children.length) && (children.getItemAt(index) is Identifier)) {
					identifier = children.getItemAt(index) as Identifier;
					returnObject = identifier.evaluate(context);
					index++;
					
					if (index < children.length) {
						index++;
					}
					else {
						// Last identifier, so let's break.
						break;
					}
					
					if (returnObject == null) {
						trace(" WARN: Unable to merge context for identifier at"
							+ " line " + identifier.line + ", column " + identifier.column + ": " + identifier.toString());
						break;
					}
				}
			}
			catch (error:ContextMergeError) {
				returnObject = null;
				trace(" WARN: Unable to merge context for identifier at"
							+ " line " + identifier.line + ", column " + identifier.column + ": " + identifier.data);
			}
			
			return returnObject;
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
			
			var referenceValue:String = evaluate(context);
			var unresolvedReference:String = context.getValue("reference.unresolved");
			
			if (referenceValue != null) {
				// The reference is valid, so we need to write out just the escape pairs, i.e. escape == \, then \\ -> \.
				while (escapeCount > 1) {
					output += ParserSettings.getInstance().delimiterSettings.escape;
					escapeCount -= 2;
				}
				
				// If we had an even number of escapes, then the reference was not escaped and can be evaluated.
				if ((escapeCount % 2) == 0) {
					output += referenceValue;
					
					if( output != null )
						fileStream.writeUTFBytes(output);
					return;
				}
			}
			else if (unresolvedReference != null) {
				fileStream.writeUTFBytes(unresolvedReference);
				return;
			}
			else {
				// We just need to write out the escapes, since the reference couldn't be resolved.
				while (escapeCount > 0) {
					output += ParserSettings.getInstance().delimiterSettings.escape;
					escapeCount--;
				}
			}
			
			fileStream.writeUTFBytes(output);
			
			// Let the super deal with the rest.
			super.merge(context, fileStream);
		}
	}
}