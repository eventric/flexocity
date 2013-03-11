package com.pcguild.flexocity.parser
{
	import com.adobe.utils.StringUtil;
	import com.pcguild.flexocity.Flexocity;
	import com.pcguild.flexocity.context.ArrayContext;
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.event.FlexocityEvent;
	import com.pcguild.flexocity.event.TemplateEvent;
	import com.pcguild.flexocity.method.CallLaterManager;
	import com.pcguild.flexocity.method.MethodCallback;
	import com.pcguild.flexocity.parser.node.Block;
	import com.pcguild.flexocity.parser.node.Identifier;
	import com.pcguild.flexocity.parser.node.IndexInput;
	import com.pcguild.flexocity.parser.node.Instruction;
	import com.pcguild.flexocity.parser.node.MethodInput;
	import com.pcguild.flexocity.parser.node.Template;
	import com.pcguild.flexocity.parser.node.Text;
	import com.pcguild.flexocity.parser.node.delimiter.AssignmentDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.DirectiveDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.EscapeDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.InDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.ReferenceDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.SequenceDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.FormalCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.FormalOpener;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.IndexCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.IndexOpener;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.MethodCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.MethodOpener;
	import com.pcguild.flexocity.parser.node.delimiter.logic.EqualsDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.GreaterThanDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.GreaterThanEqualDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.LessThanDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.LessThanEqualDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.NotEqualDelimiter;
	import com.pcguild.flexocity.parser.settings.DelimiterSettings;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	import com.pcguild.flexocity.util.CharacterUtil;
	
	import flash.events.Event;
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	import mx.core.UIComponent;
	
	/**
	 *  This class handles all the parsing of the template file into a tree
	 *  structure.
	 */
	public class Parser
	{
		/**
		 *  The delimiters for text reads.
		 */
		private var TEXT_DELIMITERS:ArrayCollection = new ArrayCollection([	ParserSettings.getInstance().delimiterSettings.directive,
																						ParserSettings.getInstance().delimiterSettings.reference	]);
		
		/**
		 *  The delimiters for method reads.
		 */
		private var METHOD_DELIMITERS:ArrayCollection = new ArrayCollection([	ParserSettings.getInstance().delimiterSettings.methodCloser,
																						ParserSettings.getInstance().delimiterSettings.directive,
																						ParserSettings.getInstance().delimiterSettings.reference,
																						ParserSettings.getInstance().delimiterSettings.inDelimiter,
																						ParserSettings.getInstance().delimiterSettings.lessThan,
																						ParserSettings.getInstance().delimiterSettings.greaterThan,
																						ParserSettings.getInstance().delimiterSettings.lessThanEquals,
																						ParserSettings.getInstance().delimiterSettings.greaterThanEquals,
																						ParserSettings.getInstance().delimiterSettings.equals,
																						ParserSettings.getInstance().delimiterSettings.notEqual,
																						ParserSettings.getInstance().delimiterSettings.assignment	]);
		
		/**
		 *  The delimiters for index reads.
		 */
		private var INDEX_DELIMITERS:ArrayCollection = new ArrayCollection([	ParserSettings.getInstance().delimiterSettings.indexCloser	]);
		
		/**
		 *  The delimiters for block comment reads.
		 */
		private var BLOCK_COMMENT_DELIMITERS:ArrayCollection = new ArrayCollection([	ParserSettings.getInstance().delimiterSettings.blockComment	]);
		
		/**
		 *  The delimiters for end of line reads.
		 */
		private var END_OF_LINE_DELIMITERS:ArrayCollection = new ArrayCollection([	ParserSettings.getInstance().delimiterSettings.endOfLine	]);
		
		/**
		 *  The page size, which is the amount read in from the file stream
		 *  each time a read is necessary.
		 */
		private static const PAGE_SIZE:int = 1024;
		
		/**
		 *  The file stream we're reading from.
		 */
		private var _fileStream:FileStream;
		
		/**
		 *  The call later manager which is used to avoid lockup.
		 */
		private var _manager:CallLaterManager;
		
		/**
		 *  The overflow buffer, which is used to store any characters that
		 *  were read but not used.
		 */
		private var _overflowBuffer:String = null;
		
		/**
		 *  The delimitier settings.
		 *  
		 * @see com.pcguild.flexocity.parser.settings.DelimiterSettings
		 */
		private var _delimiterSettings:DelimiterSettings = ParserSettings.getInstance().delimiterSettings;
		
		/**
		 *  The template we're generating.
		 */
		private var _template:Template;
		
		private var _column:int = 1;
		private var _line:int = 1;
		
		/**
		 *  Creates a new Parser.
		 *
		 * @param fileStream The file stream to read from. 
		 * @param parent The parent UIComponent used for UI updates.
		 *
		 * @return A reference to a Parser object.
		 */
		public function Parser(fileStream:FileStream, parent:UIComponent)
		{
			_fileStream = fileStream;
			_manager = new CallLaterManager(parent);
			
			var handleEvent:Function = function(event:Event=null):void
			{
				// We want to clear out the manager so no more calls occur.
				_manager.clear();
				Flexocity.removeEventListener(FlexocityEvent.TEMPLATE_GENERATED, handleEvent);
				Flexocity.removeEventListener(FlexocityEvent.TEMPLATE_ERROR, handleEvent);
			};
			
			Flexocity.addEventListener(FlexocityEvent.TEMPLATE_GENERATED, handleEvent);
			Flexocity.addEventListener(FlexocityEvent.TEMPLATE_ERROR, handleEvent);
		}
		
		/**
		 *  Initiates the parsing of the template.
		 */
		public function parse():void
		{
			_template = new Template();
			_manager.callLater(readText, [ _template ]);
		}
		
		/**
		 *  Creates and dispatches a TEMPLATE_ERROR type FlexocityEvent using
		 * 	the provided message.
		 *  
		 * @param message The message.
		 */
		private function createAndDispatchTemplateError(message:String):void
		{
			Flexocity.dispatchEvent(new FlexocityEvent(
				FlexocityEvent.TEMPLATE_ERROR,
				"Parse Error line " + _line + ", column " + _column + ": " + message));
		}
		
		/**
		 *  Advances the line and column based on the provided text.
		 *  
		 * @param text The text.
		 */
		private function advanceLineAndColumn(text:String):void
		{
			var eolSplit:Array = text.split("\n");
			var charsAfterLastEOL:String = eolSplit[eolSplit.length - 1];
			
			_line += eolSplit.length - 1;
			
			if (eolSplit.length > 1) {
				_column = (charsAfterLastEOL.length == 0) ? 1 : charsAfterLastEOL.length;
			}
			else {
				_column += charsAfterLastEOL.length;
			}
		}
		
		/**
		 *  Withdraws the line and column based on the provided text.
		 *  
		 * @param text The text.
		 */
		private function withdrawLineAndColumn(text:String):void
		{
			var eolSplit:Array = text.split("\n");
			var charsBeforeFirstEOL:String = eolSplit[0];
			
			// If we have an EOL, then our column count might be off.
			if (eolSplit.length > 1) {
				trace("Column count might be off.");
			}
			
			_line -= eolSplit.length - 1;
			_column -= charsBeforeFirstEOL.length;
		}
		
		/**
		 *  Returns the character count remaining, calculated by adding any
		 *  overflow buffer length to the available file stream bytes.
		 *  
		 * @return The count.
		 */
		private function charCountRemaining():uint
		{
			try {
				if (_overflowBuffer != null) {
					return _overflowBuffer.length + _fileStream.bytesAvailable;
				}
				else {
					return _fileStream.bytesAvailable;
				}
			}
			catch (error:Error) 
			{
				// error 2029 = file isn't open, in this case we've reached the EOF
				if( error.errorID != 2029 )
					throw new Error("Parser.charCountRemaining fileStream count remaining error: " + error.message);
			}
			
			return 0;
		}
		
		/**
		 *  Adds the string to the front of the overflow buffer, since the
		 *  characters would have come off of there if there was a buffer.
		 *  
		 * @param chars The character string.
		 */
		private function addToOverflow(chars:String):void
		{
			if (chars == null) {
				return;
			}
			
			// If there is no overflow, we need to initialize it.
			if (_overflowBuffer == null) {
				_overflowBuffer = "";
			}
			
			// We need to always add to the front of the overflow, since these chars should have come from front.
			_overflowBuffer = chars + _overflowBuffer;
		}
		
		/**
		 *  Reads a page into the buffer (see PAGE_SIZE).
		 */
		private function readIntoBuffer():void
		{
			if (_overflowBuffer == null) {
				_overflowBuffer = "";
			}
			
			_overflowBuffer += _fileStream.readUTFBytes(Math.min(_fileStream.bytesAvailable, PAGE_SIZE));
		}
		
		/**
		 *  Reads the number of characters requested, first coming from any
		 *  overflow buffer, then from the file stream.
		 *  
		 * @param count The number of characters.
		 * 
		 * @return The character string.
		 */
		private function readChars(count:int=1):String
		{
			// If we have an invalid count, just return null.
			if (count < 1) {
				return null;
			}
			
			// If we're asking to read more than what we have, just return null.
			if (count > charCountRemaining()) {
				return null;
			}
			
			var chars:String = "";
			
			// If we don't have enough buffer, we need to read into it.
			if ((_overflowBuffer == null) || (_overflowBuffer.length < count)) {
				readIntoBuffer();
			}
			
			// Remove what's needed from the buffer.
			chars = _overflowBuffer.substr(0, count);
			_overflowBuffer = _overflowBuffer.substr(count, _overflowBuffer.length - count);
			
			return chars;
		}
		
		/**
		 *  Reads until one of the specified delimiters is reached.
		 *  
		 * @param delimiters A collection of the delimiters to check for.
		 * 
		 * @return The character string.
		 */
		private function readUntilDelimiter(delimiters:ArrayCollection):String
		{
			var delimiter:String;
			var index:int = -1;
			var string:String = "";
			var buffer:String = "";
			
			// We want to keep reading until we have a delimiter.
			while (!delimiter) {
				if (!charCountRemaining()) {
					return string;
				}
				
				buffer = readChars(Math.min(charCountRemaining(), PAGE_SIZE));
				
				// Iterate through the delimiters, breaking out when we find one.
				for each (var tempDelimiter:String in delimiters) {
					var tempIndex:int = buffer.indexOf(tempDelimiter);
					
					// If we found a delimiter which is closest to the beginning, save it off.
					if ((tempIndex > -1) && ((index == -1) || (tempIndex < index))) {
						index = tempIndex;
						delimiter = tempDelimiter;
					}
				}
				
				// If we have a delimiter, read through it, and put the rest back into overflow.
				if (delimiter) {
					string += buffer.substr(0, index + delimiter.length);
					addToOverflow(buffer.substr(index + delimiter.length, buffer.length - (index + delimiter.length)));
				}
				// No delimiter, just add buffer to string.
				else {
					string += buffer;
				}
			}
			
			return string;
		}
		
		/**
		 *  Reads a shorthand identifier, if there is one. Identifier is used
		 *  here loosely to refer to the character strings which make up both
		 *  reference identifiers and directive instructions. This will not
		 *  read special instruction strings.
		 *  
		 * @return The character string.
		 */
		private function readShorthandIdentifier():String
		{
			if (!charCountRemaining()) {
				return null;
			}
			
			var char:String = readChars();
			var buffer:String = "";
			
			// If the first char is alphabetic, then this is the identifier and not something else.
			if (CharacterUtil.isAlphabetic(char)) {
				// Build the identifier, which consists of a..z, A..Z, 0..9, "-", "_".
				while (CharacterUtil.isAlphabetic(char) || CharacterUtil.isNumeric(char)
						|| char == "-" || char == "_") {
					buffer += char;
					
					// If there is no more to read, return buffer now.
					if (!charCountRemaining()) {
						return buffer;
					}
					
					char = readChars();
				}
			}
			// If the first char was not alphabetic, set the buffer to null.
			else {
				buffer = null;
			}
			
			addToOverflow(char);
			
			return buffer;
		}
		
		/**
		 *  Reads text until one of the text delimiters is found. It will then
		 *  add a text node to the given parent and signal a read of the found
		 *  delimiter.
		 *  
		 * @param parent The parent node.
		 */
		private function readText(parent:Node, fromMethodRead:Boolean=false):void
		{
			// If we're at EOF, fire parsing complete passing the template.
			if (!charCountRemaining()) {
				Flexocity.dispatchEvent(new TemplateEvent(TemplateEvent.PARSE_COMPLETE, _template));
			}
			
			var text:String = readUntilDelimiter(TEXT_DELIMITERS);
			var delimiter:String;
			var escapeCount:int = 0;
			var isReference:Boolean;
			
			if (StringUtil.endsWith(text, _delimiterSettings.reference)) {
				delimiter = _delimiterSettings.reference;
			}
			else if (StringUtil.endsWith(text, _delimiterSettings.directive)) {
				delimiter = _delimiterSettings.directive;
			}
			
			// If we have a delimiter, pop off the delimiter and all the escapes, leaving us just with the text.
			if (delimiter != null) {
				text = StringUtil.remove(text, delimiter);
				
				while (StringUtil.endsWith(text, _delimiterSettings.escape)) {
					text = text.substr(0, text.length - _delimiterSettings.escape.length);
					escapeCount++;
				}
			}
			
			// If we have text left, create a node for it.
			if (text != "") {
				new Text(text, _line, _column, parent);
				advanceLineAndColumn(text);
			}
			
			// Add an escape delimiter for each escape.
			while (escapeCount > 0) {
				new EscapeDelimiter(_line, _column, parent);
				advanceLineAndColumn(_delimiterSettings.escape);
				escapeCount--;
			}
			
			if (delimiter == _delimiterSettings.reference) {
				var reference:Node = new ReferenceDelimiter(_line, _column, parent);
				
				advanceLineAndColumn(delimiter);
				
				_manager.callLater(readIdentifier, [ reference, fromMethodRead ]);
			}
			else if (delimiter == _delimiterSettings.directive) {
				var directive:Node = new DirectiveDelimiter(_line, _column, parent);
				
				advanceLineAndColumn(delimiter);
				
				_manager.callLater(readInstruction, [ directive, fromMethodRead ]);
			}
			// If we're at EOF, fire parsing complete passing the template.
			else if (!charCountRemaining()) {
				Flexocity.dispatchEvent(new TemplateEvent(TemplateEvent.PARSE_COMPLETE, _template));
			}
		}
		
		/**
		 *  Reads an instruction, adding it to the directive parent. This will
		 *  handle the read differently depending on which instruction is
		 *  found. If not from a method read, this signals a text read when
		 *  finished.
		 *  
		 * @param parent The parent directive delimiter.
		 * @param fromMethodRead Whether this was called from a method read.
		 */
		private function readInstruction(parent:Node, fromMethodRead:Boolean=false):void
		{
			// If we're at EOF, fire parsing complete passing the template.
			if (!charCountRemaining()) {
				Flexocity.dispatchEvent(new TemplateEvent(TemplateEvent.PARSE_COMPLETE, _template));
			}
			
			var buffer:String = readShorthandIdentifier();
			var openerFound:Boolean = false;
			var instruction:Instruction;
			
			// No valid identifier was found, check for formal opener or special instruction.
			if (buffer == null) {
				// Read the length of a formal opener, so we can see if one is present.
				buffer = readChars(_delimiterSettings.formalOpener.length);
				
				// Formal opener was found, so add one to the parent. (Don't do this if shorthand is disabled)
				if (!_delimiterSettings.shorthandInstructionsDisabled && (buffer == _delimiterSettings.formalOpener)) {
					new FormalOpener(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.formalOpener);
					openerFound = true;
					
					buffer = readShorthandIdentifier();
					
					if (buffer == null) {
						createAndDispatchTemplateError("Improper instruction structure - instruction not found after formal opener.");
						
						return;
					}
				}
				// These are for the special instructions: #* and ##.
				else {
					addToOverflow(buffer);
					
					// Read the length of a block comment dilimiter, so we can see if one is present.
					buffer = readChars(_delimiterSettings.blockComment.length);
					
					// Block comment delimiter was not found, check for line comment.
					if (buffer != _delimiterSettings.blockComment) {
						addToOverflow(buffer);
						
						// Read the length of a line comment (directive) dilimiter, so we can see if one is present.
						buffer = readChars(_delimiterSettings.directive.length);
						
						// Line comment delimiter was not found, there's a problem.
						if (buffer != _delimiterSettings.directive) {
							addToOverflow(buffer);
							
							// This was not a directive like we thought it was, so remove it and add it back in as text.
							var text:Node = new Text(parent.data, _line, _column, parent.parent);
							parent.parent.removeChild(parent);
							
							// If we're not coming from a method read, then we need to read text on the parent.
							if (!fromMethodRead) {
								_manager.callLater(readText, [ text.parent ]);
							}
							
							return;
						}
					}
				}
			}
			
			// By this point, there must be an instruction on the buffer.
			instruction = new Instruction(buffer, _line, _column, parent);
			advanceLineAndColumn(buffer);
			
			var context:Context = new ArrayContext();
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadInstructionMethodRead,
													context);
			
			// Setup the context.
			context.put("parent", parent);
			context.put("openerFound", openerFound);
			context.put("fromMethodRead", fromMethodRead);
			context.put("instruction", instruction);
			
			// If the instruction is not special (not a comment), try to read a method.
			if (!instruction.isSpecialInstruction()) {
				_manager.callLater(readMethod, [ instruction ], thisCallback);
				
				return;
			}
			
			callbackReadInstructionMethodRead(thisCallback);
		}
		
		/**
		 *  This is the callback for the readMethod call in readInstruction.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadInstructionMethodRead(paramCallback:MethodCallback):void
		{
			var buffer:String;
			var instruction:Instruction = paramCallback.context.getValue("instruction");
			
			// If there should be a formal closer, read the length of one.
			if (paramCallback.context.getValue("openerFound") || _delimiterSettings.shorthandInstructionsDisabled) {
				buffer = readChars(_delimiterSettings.formalCloser.length);
				
				if (buffer == _delimiterSettings.formalCloser) {
					new FormalCloser(_line, _column, paramCallback.context.getValue("parent"));
					advanceLineAndColumn(_delimiterSettings.formalCloser);
				}
				else {
					addToOverflow(buffer);
					createAndDispatchTemplateError("Improper instruction structure - matching formal closer not found.");
					
					return;
				}
			}
			
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadInstructionTextRead,
													paramCallback.context);
			
			// BLOCK_COMMENT
			if (instruction.data == _delimiterSettings.blockComment) {
				var directiveDelimiterBuffer:String;
				
				// Reset the buffer, so we can use it for the block comment.
				buffer = "";
				
				while (true) {
					if (!charCountRemaining()) {
						createAndDispatchTemplateError("Encountered EOF before comment block finished.");
						
						return;
					}
					
					buffer += readUntilDelimiter(BLOCK_COMMENT_DELIMITERS);
					directiveDelimiterBuffer = readChars(_delimiterSettings.directive.length);
					
					// If we found a directive delimiter, then the comment block is finished.
					if (directiveDelimiterBuffer == _delimiterSettings.directive) {
						new Text(buffer + directiveDelimiterBuffer, _line, _column, new Block(_line, _column, instruction));
						advanceLineAndColumn(buffer + directiveDelimiterBuffer);
						break;
					}
					
					// The comment is not finished, so clean up and keep going.
					if (directiveDelimiterBuffer != null) {
						addToOverflow(directiveDelimiterBuffer);
					}
				}
			}
			// LINE_COMMENT
			else if (instruction.data == _delimiterSettings.directive) {
				buffer = readUntilDelimiter(END_OF_LINE_DELIMITERS);
				
				// Add text to an instruction block, but make sure to put the end of line back in the overflow.
				if (buffer != null) {
					buffer = buffer.substr(0, buffer.length - _delimiterSettings.endOfLine.length);
					
					if (buffer != "") {
						new Text(buffer, _line, _column, new Block(_line, _column, instruction));
						advanceLineAndColumn(buffer);
					}
					
					addToOverflow(_delimiterSettings.endOfLine);
				}
			}
			// Other block instructions.
			else if (instruction.isBlockInstruction()) {
				// Middle instructions need to be pulled out of the block to the same level as its siblings.
				if (instruction.isMiddleInstruction()) {
					instruction.moveOutOfBlock();
				}
				
				_manager.callLater(readText, [ new Block(_line, _column, instruction), paramCallback.context.getValue("fromMethodRead") ], thisCallback);
				
				return;
			}
			// Eat the rest of the line after closing instructions if only an endOfLine exists.
			else if (instruction.isClosingInstruction()) {
				// Closing instructions, like middle instructions, need to be moved out of the block.
				instruction.moveOutOfBlock();
				
				return;
			}
			
			callbackReadInstructionTextRead(thisCallback);
		}
		
		/**
		 *  This is the callback for the readText call in readInstruction.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadInstructionTextRead(paramCallback:MethodCallback):void
		{
			// Finally, read text only once and not for method reads.
			if (!paramCallback.context.getValue("fromMethodRead")) {
				_manager.callLater(readText, [ paramCallback.context.getValue("parent").parent ]);
			}
		}
		
		/**
		 *  Reads an identifier, adding it to the reference parent. This will
		 *  recursively call itself until the whole identifier chain is read.
		 *  If not from a method or identifier read, this signals a text read
		 *  when finished.
		 *  
		 * @param parent The parent reference delimiter.
		 * @param fromMethodRead Whether this was called from a method read.
		 * @param fromIdRead Whether this was called from an identifier read.
		 */
		private function readIdentifier(parent:Node, fromMethodRead:Boolean=false, fromIdRead:Boolean=false):void
		{
			// If we're at EOF, fire parsing complete passing the template.
			if (!charCountRemaining()) {
				Flexocity.dispatchEvent(new TemplateEvent(TemplateEvent.PARSE_COMPLETE, _template));
			}
			
			var buffer:String = readShorthandIdentifier();
			var openerFound:Boolean = false;
			var identifier:Identifier;
			
			// If we came from an identifier read, we don't want to check for a formal opener.
			if (fromIdRead && (buffer == null)) {
				_manager.setErrorCode(MethodCallback.DEFAULT_ERROR);
				
				return;
			}
			
			// If we have shorthand disabled, there should have been an identifier found.
			if (_delimiterSettings.shorthandIdentifiersDisabled && (buffer == null)) {
				createAndDispatchTemplateError("Improper identifier structure - identifier not found after formal opener.");
				
				return;
			}
			
			// No valid identifier was found, check for formal opener.
			if (buffer == null) {
				// Read the length of a formal opener, so we can see if one is present.
				buffer = readChars(_delimiterSettings.formalOpener.length);
				
				// Formal opener was found, so add one to the parent.
				if (buffer == _delimiterSettings.formalOpener) {
					new FormalOpener(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.formalOpener);
					openerFound = true;
					
					buffer = readShorthandIdentifier();
					
					if (buffer == null) {
						createAndDispatchTemplateError("Improper identifier structure - identifier not found after formal opener.");
						
						return;
					}
				}
				else {
					addToOverflow(buffer);
					
					if (!fromIdRead) {
						// This was not a reference like we thought it was, so remove it and add it back in as text.
						var text:Node = new Text(parent.data, _line, _column, parent.parent);
						parent.parent.removeChild(parent);
						
						// If we're not coming from a method read, then we need to read text on the parent.
						if (!fromMethodRead) {
							_manager.callLater(readText, [ text.parent ]);
						}
						
						return;
					}
					else {
						createAndDispatchTemplateError("Improper identifier structure - neither identifier nor formal opener found after reference delimiter.");
						
						return;
					}
				}
			}
			
			// By this point, there must be an identifer on the buffer.
			identifier = new Identifier(buffer, _line, _column, parent);
			advanceLineAndColumn(buffer);
			
			var context:Context = new ArrayContext();
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadIdentifierMethodRead,
													context);
			
			// Setup the context.
			context.put("parent", parent);
			context.put("fromMethodRead", fromMethodRead);
			context.put("fromIdRead", fromIdRead);
			context.put("openerFound", openerFound);
			context.put("identifier", identifier);
			
			// Attempt to read a method.
			_manager.callLater(readMethod, [ identifier ], thisCallback);
		}
		
		/**
		 *  This is the callback for the readMethod call in readIdentifier.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadIdentifierMethodRead(paramCallback:MethodCallback):void
		{
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadIdentifierIndexRead,
													paramCallback.context);
			
			// Attempt to read an index.
			_manager.callLater(readIndex, [ paramCallback.context.getValue("identifier") ], thisCallback);
		}
		
		/**
		 *  This is the callback for the readIndex call in readIdentifier.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadIdentifierIndexRead(paramCallback:MethodCallback):void
		{
			var buffer:String;
			var parent:Node = paramCallback.context.getValue("parent");
			
			// We need to check for a sequence.
			// Read the length of a sequence delimiter, so we can see if one is present.
			buffer = readChars(_delimiterSettings.sequence.length);
			
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadIdentifierIdentifierRead,
													paramCallback.context);
			
			// Sequence delimiter was found, so add one to the parent.
			if (buffer == _delimiterSettings.sequence) {
				var sequenceDelimiter:SequenceDelimiter = new SequenceDelimiter(_line, _column, parent);
				advanceLineAndColumn(_delimiterSettings.sequence);
				
				paramCallback.context.put("buffer", buffer);
				paramCallback.context.put("sequenceDelimiter", sequenceDelimiter);
				
				_manager.callLater(readIdentifier, [ parent, paramCallback.context.getValue("fromMethodRead"), true ], thisCallback);
				
				return;
			}
			else if (buffer != null) {
				addToOverflow(buffer);
			}
			
			callbackReadIdentifierIdentifierRead(thisCallback);
		}
		
		/**
		 *  This is the callback for the readIdentifier call in readIdentifier.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadIdentifierIdentifierRead(paramCallback:MethodCallback):void
		{
			var buffer:String;
			var parent:Node = paramCallback.context.getValue("parent");
			
			// Remove the sequence delimiter if we get an error, since it doesn't belong to the identifier sequence.
			if (paramCallback.hasError()) {
				addToOverflow(paramCallback.context.getValue("buffer"));
				parent.removeChild(paramCallback.context.getValue("sequenceDelimiter"));
				withdrawLineAndColumn(_delimiterSettings.sequence);
			}
			
			// If there should be a formal closer, read the length of one.
			if (!paramCallback.context.getValue("fromIdRead") && (paramCallback.context.getValue("openerFound") || _delimiterSettings.shorthandIdentifiersDisabled)) {
				buffer = readChars(_delimiterSettings.formalCloser.length);
				
				if (buffer == _delimiterSettings.formalCloser) {
					new FormalCloser(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.formalCloser);
				}
				else {
					addToOverflow(buffer);
					createAndDispatchTemplateError("Improper identifier structure - matching formal closer not found.");
					
					return;
				}
			}
			
			// Finally, read text only once and not for method reads.
			if (!paramCallback.context.getValue("fromIdRead") && !paramCallback.context.getValue("fromMethodRead")) {
				_manager.callLater(readText, [ parent.parent ]);
			}
		}
		
		/**
		 *  Reads a method, adding it to the given parent identifier or
		 *  instruction.
		 *  
		 * @param parent The parent identifier or instruction.
		 */
		private function readMethod(parent:Node):void
		{
			// Read the length of a method opener, so we can see if one is present.
			var buffer:String = readChars(_delimiterSettings.methodOpener.length);
			
			var context:Context = new ArrayContext();
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadMethodMethodInputRead,
													context);
			
			// Method opener was found, so add one to the parent.
			if (buffer == _delimiterSettings.methodOpener) {
				new MethodOpener(_line, _column, parent);
				advanceLineAndColumn(_delimiterSettings.methodOpener);
				
				context.put("parent", parent);
				
				_manager.callLater(readMethodInput, [ new MethodInput(_line, _column, parent) ], thisCallback);
			}
			else {
				addToOverflow(buffer);
			}
		}
		
		/**
		 *  This is the callback for the readMethodInput call in readMethod.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadMethodMethodInputRead(paramCallback:MethodCallback):void
		{
			var buffer:String;
			
			// Read the length of a method closer, so we can see if one is present.
			buffer = readChars(_delimiterSettings.methodCloser.length);
			
			// Method closer was found, so add one to the parent.
			if (buffer == _delimiterSettings.methodCloser) {
				new MethodCloser(_line, _column, paramCallback.context.getValue("parent"));
				advanceLineAndColumn(_delimiterSettings.methodCloser);
			}
			else if (buffer == null) {
				createAndDispatchTemplateError("Encountered EOF before method closer found.");
			}
			// This should never happen...but just in case.
			else {
				addToOverflow(buffer);
				createAndDispatchTemplateError("Major problem - method closer not found but we're also not at EOF.");
			}
		}
		
		/**
		 *  Reads the method input, which is comprised of general method
		 *  parameters separated by a delimiter. This delimiter can be
		 *  something like a param delimiter or an assignment delimiter. For
		 *  identifiers, it will always be a param delimiter. For instructions,
		 *  it will depend on what the instruction is. Anything read is added
		 *  to the parent method input.
		 *  
		 * @param parent The method input to read into.
		 */
		private function readMethodInput(parent:Node):void
		{
			var text:String = readUntilDelimiter(METHOD_DELIMITERS);
			var delimiter:String;
			var escapeCount:int = 0;
			var isReference:Boolean;
			
			// Find the delimiter.
			for each (delimiter in METHOD_DELIMITERS) {
				if (StringUtil.endsWith(text, delimiter)) {
					break;
				}
				else {
					delimiter = null;
				}
			}
			
			// No delimiter was found, which means we hit EOF without one.
			if (delimiter == null) {
				createAndDispatchTemplateError("Encountered EOF before method delimiter found.");
				
				return;
			}
			
			text = StringUtil.remove(text, delimiter);
			
			// If we have a directive or reference delimiter, pop off all the escapes, leaving us just with the text.
			if ((delimiter == _delimiterSettings.directive) || (delimiter == _delimiterSettings.reference)) {
				while (StringUtil.endsWith(text, _delimiterSettings.escape)) {
					text = text.substr(0, text.length - _delimiterSettings.escape.length);
					escapeCount++;
				}
			}
			
			// If we have text left, create a node for it.
			if (text != "") {
				new Text(text, _line, _column, parent);
				advanceLineAndColumn(text);
			}
			
			// Add an escape delimiter for each escape.
			while (escapeCount > 0) {
				new EscapeDelimiter(_line, _column, parent);
				advanceLineAndColumn(_delimiterSettings.escape);
				escapeCount--;
			}
			
			var context:Context = new ArrayContext();
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadMethodInputMulti,
													context);
			
			context.put("parent", parent);
			
			// We want to handle each, but if a method closer, we're done here.
			switch (delimiter) {
				case _delimiterSettings.methodCloser:
					addToOverflow(delimiter);
					return;
				case _delimiterSettings.reference:
					var reference:Node = new ReferenceDelimiter(_line, _column, parent);
					
					advanceLineAndColumn(_delimiterSettings.reference);
					
					_manager.callLater(readIdentifier, [ reference, true ], thisCallback);
					return;
				case _delimiterSettings.directive:
					var directive:Node = new DirectiveDelimiter(_line, _column, parent);
					
					advanceLineAndColumn(_delimiterSettings.directive);
					
					_manager.callLater(readInstruction, [ directive, true ], thisCallback);
					return;
				case _delimiterSettings.inDelimiter:
					new InDelimiter(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.inDelimiter);
					break;
				case _delimiterSettings.assignment:
					// We need to handle if the equals delimiter starts with the assignment delimiter.
					if (StringUtil.beginsWith(_delimiterSettings.equals, _delimiterSettings.assignment)) {
						text = readChars(_delimiterSettings.equals.length - _delimiterSettings.assignment.length);
						
						// If we have an equals, add it.
						if (_delimiterSettings.equals == (delimiter + text)) {
							new EqualsDelimiter(_line, _column, parent);
							advanceLineAndColumn(_delimiterSettings.equals);
						}
						// If we don't, add an assignment and put the text back in the overflow.
						else {
							if (text) {
								addToOverflow(text);
							}
							
							new AssignmentDelimiter(_line, _column, parent);
							advanceLineAndColumn(_delimiterSettings.assignment);
						}
					}
					else {
						new AssignmentDelimiter(_line, _column, parent);
						advanceLineAndColumn(_delimiterSettings.assignment);
					}
					break;
				case _delimiterSettings.lessThan:
					new LessThanDelimiter(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.lessThan);
					break;
				case _delimiterSettings.greaterThan:
					new GreaterThanDelimiter(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.greaterThan);
					break;
				case _delimiterSettings.lessThanEquals:
					new LessThanEqualDelimiter(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.lessThanEquals);
					break;
				case _delimiterSettings.greaterThanEquals:
					new GreaterThanEqualDelimiter(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.greaterThanEquals);
					break;
				case _delimiterSettings.equals:
					new EqualsDelimiter(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.equals);
					break;
				case _delimiterSettings.notEqual:
					new NotEqualDelimiter(_line, _column, parent);
					advanceLineAndColumn(_delimiterSettings.notEqual);
					break;
			}
			
			callbackReadMethodInputMulti(thisCallback);
		}
		
		/**
		 *  This is the callback for multiple calls in readMethodInput.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadMethodInputMulti(paramCallback:MethodCallback):void
		{
			_manager.callLater(readMethodInput, [ paramCallback.context.getValue("parent") ]);
		}
		
		/**
		 *  Reads an index, adding it to the given parent idenfitier.
		 *  
		 * @param parent The parent identifier.
		 */
		private function readIndex(parent:Identifier):void
		{
			// Read the length of an index opener, so we can see if one is present.
			var buffer:String = readChars(_delimiterSettings.indexOpener.length);
			
			var context:Context = new ArrayContext();
			var thisCallback:MethodCallback = new MethodCallback(
													callbackReadIndexIndexInputRead,
													context);
			
			// Index opener was found, so add one to the parent.
			if (buffer == _delimiterSettings.indexOpener) {
				new IndexOpener(_line, _column, parent);
				advanceLineAndColumn(_delimiterSettings.indexOpener);
				
				context.put("parent", parent);
				
				_manager.callLater(readIndexInput, [ new IndexInput(_line, _column, parent) ], thisCallback);
			}
			else {
				addToOverflow(buffer);
			}
		}
		
		/**
		 *  This is the callback for the readIndexInput call in readIndex.
		 *  
		 * @param paramCallback The callback, which will contain the context
		 * and any possible error code.
		 */
		private function callbackReadIndexIndexInputRead(paramCallback:MethodCallback):void
		{
			var buffer:String;
			
			// Read the length of an index closer, so we can see if one is present.
			buffer = readChars(_delimiterSettings.indexCloser.length);
			
			// Index closer was found, so add one to the parent.
			if (buffer == _delimiterSettings.indexCloser) {
				new IndexCloser(_line, _column, paramCallback.context.getValue("parent"));
				advanceLineAndColumn(_delimiterSettings.indexCloser);
			}
			else if (buffer == null) {
				createAndDispatchTemplateError("Encountered EOF before index closer found.");
			}
			// This should never happen...but just in case.
			else {
				addToOverflow(buffer);
				createAndDispatchTemplateError("Major problem - index closer not found but we're also not at EOF.");
			}
		}
		
		/**
		 *  Reads the index input, which can be text or possibly a reference or
		 *  directive. Anything read is added to the parent index input.
		 *  
		 * @param parent The index input to read into.
		 */
		private function readIndexInput(parent:IndexInput):void
		{
			var text:String = readUntilDelimiter(INDEX_DELIMITERS);
			var delimiter:String;
			var escapeCount:int = 0;
			var isReference:Boolean;
			
			// Find the delimiter.
			for each (delimiter in INDEX_DELIMITERS) {
				if (StringUtil.endsWith(text, delimiter)) {
					break;
				}
				else {
					delimiter = null;
				}
			}
			
			// No delimiter was found, which means we hit EOF without one.
			if (delimiter == null) {
				createAndDispatchTemplateError("Encountered EOF before index delimiter found.");
				
				return;
			}
			
			text = StringUtil.remove(text, delimiter);
			
			// If we have a directive or reference delimiter, pop off all the escapes, leaving us just with the text.
//			if ((delimiter == _delimiterSettings.directive) || (delimiter == _delimiterSettings.reference)) {
//				while (StringUtil.endsWith(text, _delimiterSettings.escape)) {
//					text = text.substr(0, text.length - _delimiterSettings.escape.length);
//					escapeCount++;
//				}
//			}
			
			// If we have text left, create a node for it.
			if (text != "") {
				new Text(text, _line, _column, parent);
				advanceLineAndColumn(text);
			}
			
			// Add an escape delimiter for each escape.
//			while (escapeCount > 0) {
//				new EscapeDelimiter(parent);
//				escapeCount--;
//			}
			
			// We want to handle each, but if a index closer, we're done here.
			switch (delimiter) {
				case _delimiterSettings.indexCloser:
					addToOverflow(delimiter);
					return;
//				case _delimiterSettings.reference:
//					readIdentifier(new ReferenceDelimiter(parent), true);
//					break;
//				case _delimiterSettings.directive:
//					readInstruction(new DirectiveDelimiter(parent));
//					break;
			}
			
//			readIndexInput(parent);
		}
	}
}