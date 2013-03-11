package com.pcguild.flexocity.parser.node
{
	import com.adobe.utils.StringUtil;
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ContextMergeError;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.delimiter.DirectiveDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.EscapeDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.ReferenceDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.MethodCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.MethodOpener;
	import com.pcguild.flexocity.parser.settings.ParserSettings;
	import com.pcguild.flexocity.util.ArrayUtil;
	
	/**
	 *  An instruction for how to process parameters and/or blocks.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class Instruction extends Node
	{
		/**
		 *  End instruction string.
		 */
		public static const END:String = "end";
		
		/**
		 *  Foreach instruction string.
		 */
		public static const FOREACH:String = "foreach";
		
		/**
		 *  Set instruction string.
		 */
		public static const SET:String = "set";
		
		/**
		 *  If instruction string.
		 */
		public static const IF:String = "if";
		
		/**
		 *  Else if instruction string.
		 */
		public static const ELSEIF:String = "elseif";
		
		/**
		 *  Else instruction string.
		 */
		public static const ELSE:String = "else";
		
		/**
		 *  The method input for this instruction. This will be null if there is none.
		 */
		private var _methodInput:MethodInput;
		
		/**
		 *  The block for this instruction. This will be null if there is none.
		 */
		private var _block:Block;
		
		/**
		 *  Instructions which are dependent upon this instruction to handle
		 *  their evaluate/merge. An example is else if and else being
		 *  dependent on if.
		 */
		private var _dependentInstructions:Array = new Array();
		
		/**
		 *  Creates a new Instruction.
		 * 
		 * @param data The node data.
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new node.
		 * 
		 * @return A reference to a Instruction object.
		 */
		public function Instruction(data:String, line:int, column:int, parent:Node=null)
		{
			super(data, line, column, parent);
		}
		
		/**
		 *  Returns whether is this a special instruction.
		 * 
		 * @return Whether this is a special instruction.
		 */
		public function isSpecialInstruction():Boolean
		{
			switch (data) {
				case /* LINE_COMMENT: */ParserSettings.getInstance().delimiterSettings.directive:
				case /* BLOCK_COMMENT: */ParserSettings.getInstance().delimiterSettings.blockComment:
					return true;
				default:
					return false;
			}
		}
		
		/**
		 *  Returns whether is this a block instruction.
		 * 
		 * @return Whether this is a block instruction.
		 */
		public function isBlockInstruction():Boolean
		{
			switch (data) {
				case /* LINE_COMMENT: */ParserSettings.getInstance().delimiterSettings.directive:
				case /* BLOCK_COMMENT: */ParserSettings.getInstance().delimiterSettings.blockComment:
				case FOREACH:
				case IF:
				case ELSEIF:
				case ELSE:
					return true;
				default:
					return false;
			}
		}
		
		/**
		 *  Returns whether is this an opening instruction.
		 * 
		 * @return Whether this is an opening instruction.
		 */
		public function isOpeningInstruction():Boolean
		{
			switch (data) {
				case FOREACH:
				case IF:
					return true;
				default:
					return false;
			}
		}
		
		/**
		 *  Returns whether is this a middle instruction.
		 * 
		 * @return Whether this is a middle instruction.
		 */
		public function isMiddleInstruction():Boolean
		{
			switch (data) {
				case ELSEIF:
				case ELSE:
					return true;
				default:
					return false;
			}
		}
		
		/**
		 *  Returns whether is this a closing instruction.
		 * 
		 * @return Whether this is a closing instruction.
		 */
		public function isClosingInstruction():Boolean
		{
			switch (data) {
				case END:
					return true;
				default:
					return false;
			}
		}
		
		/**
		 *  Moves this instruction's directive out of its current block and
		 *  into either the block or template above.
		 */
		public function moveOutOfBlock():void
		{
			// The parent should be a directive, but if its parent is a block
			// and its parent's parent is not a special instruction, proceed.
			// We don't want to move things out of comment blocks.
			if ((parent.parent is Block) && !Instruction(parent.parent.parent).isSpecialInstruction()) {
				// Yes, this chain is nasty.
				// parent -> directive -> instruction -> block -> directive -> this
				var newParent:Node = parent.parent.parent.parent.parent;
				
				// Remove the parent from its block parent.
				parent.parent.removeChild(parent);
				
				// Add the parent to the new parent.
				newParent.addChild(parent);
			}
		}
		
		/**
		 *  General validation for instructions.
		 */
		private function generalValidate():void
		{
			// For just a Block, pass down the validation.
			if ((children.length == 1) && (children.getItemAt(0) is Block)) {
				_block = Block(children.getItemAt(0));
				_block.validate();
			}
			// For a MethodInput with opener/closer, just pass down to MethodInput.
			else if ((children.length == 3) && (children.getItemAt(0) is MethodOpener)
					&& (children.getItemAt(1) is MethodInput) && (children.getItemAt(2) is MethodCloser)) {
				_methodInput = MethodInput(children.getItemAt(1));
				_methodInput.validate();
			}
			// For a MethodInput with opener/closer and Block, pass down to MethodInput and Block.
			else if ((children.length == 4) && (children.getItemAt(0) is MethodOpener)
					&& (children.getItemAt(1) is MethodInput) && (children.getItemAt(2) is MethodCloser)
					&& (children.getItemAt(3) is Block)) {
				_methodInput = MethodInput(children.getItemAt(1));
				_methodInput.validate();
				_block = Block(children.getItemAt(3));
				_block.validate();
			}
			// Bad structure.
			else {
				throw new ValidationError(this, "Instruction structure is invalid.");
			}
			
			// If we have a block instruction without a block, it's invalid.
			if ((_block == null) && isBlockInstruction()) {
				throw new ValidationError(this, "Block instruction is missing its block.");
			}
			
			// If we have a block without being a block instruction, it's invalid.
			if ((_block != null) && !isBlockInstruction()) {
				throw new ValidationError(this, "Block exits for non-block instruction.");
			}
		}
		
		/**
		 *  Special validation for if instructions.
		 */
		private function ifValidate():void
		{
			var index:int = parent.parent.children.getItemIndex(parent);
			var previousInstruction:String = data;
			
			index++;
			
			// We want to iterate through each of the siblings of this instruction's directive.
			// We'll be validating the if/else if/else/end structure.
			while (index < parent.parent.children.length) {
				var current:Node = parent.parent.children[index] as Node;
				
				if (current is Text) {
					if (!Text(current).isWhitespace) {
						throw new ValidationError(current, "Non-whitespace text found before if/end pair found: " + current);
					}
				}
				else if (current is ReferenceDelimiter) {
					throw new ValidationError(current, "Reference found before if/end pair found: " + current);
				}
				else if (current is EscapeDelimiter) {
					throw new ValidationError(current, "Escape found before if/end pair found: " + current);
				}
				else if (current is DirectiveDelimiter) {
					current.validate();
					
					var end:Boolean = false;
					var instruction:Instruction = DirectiveDelimiter(current).instruction;
					
					// We expect else if and else to come after if and else if.
					// We expect end to come after if, else if, and else.
					// Any else if and else instructions are dependent on if, so add them.
					switch (instruction.data) {
						case ELSEIF:
						case ELSE:
							if ((previousInstruction != IF) && (previousInstruction != ELSEIF)) {
								throw new ValidationError(current, "Improper structure: " + instruction.data + " cannot follow " + previousInstruction + ".");
							}
							_dependentInstructions.push(instruction);
							previousInstruction = instruction.data;
							break;
						case END:
							if ((previousInstruction != IF) && (previousInstruction != ELSEIF)
								&& (previousInstruction != ELSE)) {
								throw new ValidationError(current, "Improper structure: " + instruction.data + " cannot follow " + previousInstruction + ".");
							}
							end = true;
							break;
						default:
							throw new ValidationError(current, "Improper structure: " + instruction.data + " cannot follow " + previousInstruction + ".");
					}
					
					if (end) {
						break;
					}
				}
				else {
					throw new ValidationError(current, "Unexpected node type after if directive: " + current);
				}
				
				index++;
			}
		}
		
		/**
		 *  Returns the value of the node using the given context. This value
		 *  will be converted to the appropriate type: literal string to
		 *  string, true/false to Boolean, and anything else to Number.
		 *  
		 * @param node The node we're getting the value from.
		 * @param context The context to use for getting the value.
		 * @return The value.
		 */
		private function getValue(node:Node, context:Context):*
		{
			var value:* = node.evaluate(context);
			var valueString:String;
			
			// If this is not a reference value, we should try to do some processing.
			if (!(node is ReferenceDelimiter) && (value is String)) {
				valueString = value as String;
				
				// Remove whitespace.
				valueString = StringUtil.trim(valueString);
				
				// Remove any double quotes and set the value as the string.
				if (StringUtil.beginsWith(valueString, ParserSettings.getInstance().delimiterSettings.doubleQuote)
					&& StringUtil.endsWith(valueString, ParserSettings.getInstance().delimiterSettings.doubleQuote)) {
					value = valueString.substr(1, valueString.length - 2);
				}
				// Remove any single quotes and set the value as the string.
				else if (StringUtil.beginsWith(valueString, ParserSettings.getInstance().delimiterSettings.singleQuote)
					&& StringUtil.endsWith(valueString, ParserSettings.getInstance().delimiterSettings.singleQuote)) {
					value = valueString.substr(1, valueString.length - 2);
				}
				else if (valueString == "true") {
					value = true;
				}
				else if (valueString == "false") {
					value = false;
				}
				else if (valueString == "null") {
					value = null;
				}
				// If not a string literal, must be a number.
				else {
					value = Number(valueString);
				}
			}
			
			return value;
		}
		
		/**
		 *  Returns the reference from the node using the given context.
		 *  
		 * @param node The node we're getting the reference from.
		 * @param context The context to use for getting the reference.
		 * @return The reference.
		 */
		private function getReference(node:Node, context:Context):ReferenceDelimiter
		{
			if (node is ReferenceDelimiter) {
				return node as ReferenceDelimiter;
			}
			else if (node is DirectiveDelimiter) {
				var value:* = DirectiveDelimiter(node).evaluate(context);
				
				if (value is ReferenceDelimiter) {
					return value;
				}
			}
			
			return null;
		}
		
		/**
		 *  Comparison-specific evaluate, returning whether the expression is
		 *  true.
		 *  
		 * @param methodInput The method input used for evaluation.
		 * @param context The context used for evaluation.
		 * @return Whether the expression is true.
		 */
		private function comparisonEvaluate(methodInput:MethodInput, context:Context):Boolean
		{
			var value1:* = getValue(methodInput.parameters[0] as Node, context);
			var value2:* = getValue(methodInput.parameters[1] as Node, context);
			
			switch (methodInput.delimiter) {
				case ParserSettings.getInstance().delimiterSettings.lessThan:
					return value1 < value2;
				case ParserSettings.getInstance().delimiterSettings.greaterThan:
					return value1 > value2;
				case ParserSettings.getInstance().delimiterSettings.lessThanEquals:
					return value1 <= value2;
				case ParserSettings.getInstance().delimiterSettings.greaterThanEquals:
					return value1 >= value2;
				case ParserSettings.getInstance().delimiterSettings.equals:
					return value1 == value2;
				case ParserSettings.getInstance().delimiterSettings.notEqual:
					return value1 != value2;
				default:
					throw new ContextMergeError(methodInput, "Unknown method delimiter for comparison: " + methodInput.delimiter + ".");
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function validate():void
		{
			switch (data) {
				case /* LINE_COMMENT: */ParserSettings.getInstance().delimiterSettings.directive:
				case /* BLOCK_COMMENT: */ParserSettings.getInstance().delimiterSettings.blockComment:
					generalValidate();
					
					break;
				case SET:
					generalValidate();
					
					try {
						_methodInput.assignmentDelimiterValidate();
					}
					catch (error:ValidationError) {
						throw new ValidationError(this, "Invalid method structure for instruction: " + data);
					}
					
					break;
				case FOREACH:
					generalValidate();
					
					try {
						_methodInput.inDelimiterValidate();
					}
					catch (error:ValidationError) {
						throw new ValidationError(this, "Invalid method structure for instruction: " + data);
					}
					
					break;
				case IF:
					ifValidate();
				case ELSEIF:
					generalValidate();
					
					try {
						_methodInput.comparisonDelimiterValidate();
					}
					catch (error:ValidationError) {
						throw new ValidationError(this, "Invalid method structure for instruction: " + data);
					}
					
					break;
				case ELSE:
					generalValidate();
					
					break;
				case END:
					if (children != null) {
						throw new ValidationError(this, "Children exist for an end directive.");
					}
					
					if (_methodInput != null) {
						throw new ValidationError(this, "Method Input exists for an end directive.");
					}
					
					if (_block != null) {
						throw new ValidationError(this, "Block exists for an end directive.");
					}
					
					break;
				default:
					throw new ValidationError(this, "An unrecognized instruction was provided.");
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function evaluate(context:Context):*
		{
			var output:String = "";
			
			switch (data) {
				case FOREACH:
					var settingReference:ReferenceDelimiter = getReference(_methodInput.parameters[0], context);
					var collectionReference:ReferenceDelimiter = getReference(_methodInput.parameters[1], context);
					var counterName:String = context.getValue("directive.foreach.counter.name");
					var maxLoops:int = context.getValue("directive.foreach.maxloops");
					var array:Array;
					var length:int;
					
					if (settingReference == null) {
						throw new ContextMergeError(_methodInput.parameters[0],
							"Left foreach parameter did not evaluate into reference.");
					}
					
					if (collectionReference == null) {
						throw new ContextMergeError(_methodInput.parameters[1],
							"Right foreach parameter did not evaluate into reference.");
					}
					
					var collectionObject:* = collectionReference.evaluate(context);
					
					try {
						array = ArrayUtil.toArray(collectionObject);
						length = (maxLoops == -1) ? array.length : Math.min(maxLoops, array.length);
					}
					catch (error:Error) {
						throw new ContextMergeError(collectionReference,
							"Foreach collection not a recognized array type: " + collectionObject + ".");
					}
					
					// Initialize the counter.
					context.put(counterName, context.getValue("directive.foreach.counter.initial.value"));
					
					for (var index:int = 0; index < length; index++) {
						settingReference.setValue(array[index], context);
						
						var blockEval:* = _block.evaluate(context);
						
						if (blockEval is ReferenceDelimiter) {
							output += ReferenceDelimiter(blockEval).evaluate(context);
						}
						else {
							output += blockEval;
						}
						
						context.put(counterName, context.getValue(counterName) + 1);
					}
					
					return output;
				case IF:
					// If the if expression is true, we want to use its output.
					if (comparisonEvaluate(_methodInput, context)) {
						return _block.evaluate(context);
					}
					// We want to check each dependent instruction until we find an expression
					// that's true. Else doesn't have an expression, so just output if we reach one.
					else {
						for each (var instruction:Instruction in _dependentInstructions) {
							if ((instruction.data == ELSE) || comparisonEvaluate(instruction._methodInput, context)) {
								return instruction._block.evaluate(context);
							}
						}
					}
					
					return output;
				case SET:
					var setReference:ReferenceDelimiter = getReference(_methodInput.parameters[0], context);
					
					if (setReference == null) {
						throw new ContextMergeError(_methodInput.parameters[0],
							"Set parameter did not evaluate into reference.");
					}
					
					setReference.setValue(getValue(_methodInput.parameters[1] as Node, context), context);
				default:
					// There is no output to these instructions.
					return "";
			}
		}
	}
}