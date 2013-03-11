package com.pcguild.flexocity.parser.node
{
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.delimiter.AssignmentDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.DirectiveDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.EscapeDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.InDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.ParamDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.ReferenceDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.EqualsDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.GreaterThanDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.GreaterThanEqualDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.LessThanDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.LessThanEqualDelimiter;
	import com.pcguild.flexocity.parser.node.delimiter.logic.NotEqualDelimiter;
	
	/**
	 *  The provided input for the method.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class MethodInput extends Node
	{
		/**
		 *  The parameters for this method input.
		 */
		private var _parameters:Array = new Array();
		
		/**
		 *  The delimiter between parameters.
		 */
		private var _delimiter:String;
		
		/**
		 *  Creates a new MethodInput.
		 * 
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new node.
		 * 
		 * @return A reference to a MethodInput object.
		 */
		public function MethodInput(line:int, column:int, parent:Node=null)
		{
			super("", line, column, parent);
		}
		
		/**
		 *  Returns the parameters of this method input. This will be empty
		 *  until one of the specific validate methods is called.
		 *  
		 * @return The parameters.
		 */
		public function get parameters():Array
		{
			return _parameters;
		}
		
		/**
		 *  Returns the delimiter of this method input. This will be null
		 *  until one of the specific validate methods is called.
		 *  
		 * @return The delimiter.
		 */
		public function get delimiter():String
		{
			return _delimiter;
		}
		
		/**
		 *  Validates whether there's a reference or directive at the given
		 *  location.
		 *  
		 * @param index The index to check for a reference or directive.
		 * @return The index we finished on.
		 */
		private function referenceOrDirectiveValidate(index:int):int
		{
			// If we have text, we need to make sure it's whitespace.
			if ((index < children.length) && (children.getItemAt(index) is Text)) {
				if (!Text(children.getItemAt(index)).isWhitespace) {
					throw new ValidationError(this, "Method input not supported.");
				}
				
				index++;
			}
			
			// We should have a reference or directive here, so add it to the parameters.
			if ((index < children.length)
				&& ((children.getItemAt(index) is ReferenceDelimiter)
					|| (children.getItemAt(index) is DirectiveDelimiter))) {
				_parameters.push(children.getItemAt(index));
				index++;
				
				// If we had a delimiter, we need to iterate past any dependent directives.
				if (children.getItemAt(index - 1) is DirectiveDelimiter) {
					while ((index < children.length) && (children.getItemAt(index) is DirectiveDelimiter)) {
						index++;
					}
				}
			}
			else {
				throw new ValidationError(this, "Method input not supported.");
			}
			
			// If we have text, we need to make sure it's whitespace.
			if ((index < children.length) && (children.getItemAt(index) is Text)) {
				if (!Text(children.getItemAt(index)).isWhitespace) {
					throw new ValidationError(this, "Method input not supported.");
				}
				
				index++;
			}
			
			return index;
		}
		
		/**
		 *  Validates whether there's a reference, directive, or text at the
		 *  given location.
		 *  
		 * @param index The index to check for a reference, directive, or text.
		 * @return The index we finished on.
		 */
		private function referenceOrDirectiveOrTextValidate(index:int):int
		{
			// If we have text, we need to make sure it's whitespace.
			// If it's not, then we should just have text here.
			if ((index < children.length) && (children.getItemAt(index) is Text)) {
				if (!Text(children.getItemAt(index)).isWhitespace) {
					_parameters.push(children.getItemAt(index));
					index++;
					return index;
				}
				
				index++;
			}
			
			// We should have a reference or directive here, so add it to the parameters.
			if ((index < children.length)
				&& ((children.getItemAt(index) is ReferenceDelimiter)
					|| (children.getItemAt(index) is DirectiveDelimiter))) {
				_parameters.push(children.getItemAt(index));
				index++;
				
				// If we had a delimiter, we need to iterate past any dependent directives.
				if (children.getItemAt(index - 1) is DirectiveDelimiter) {
					while ((index < children.length) && (children.getItemAt(index) is DirectiveDelimiter)) {
						index++;
					}
				}
			}
			else {
				throw new ValidationError(this, "Method input not supported.");
			}
			
			// If we have text, we need to make sure it's whitespace.
			if ((index < children.length) && (children.getItemAt(index) is Text)) {
				if (!Text(children.getItemAt(index)).isWhitespace) {
					throw new ValidationError(this, "Method input not supported.");
				}
				
				index++;
			}
			
			return index;
		}
		
		/**
		 *  Validates the method input for what would be expected for an in delimiter.
		 */
		public function inDelimiterValidate():void
		{
			var index:int = 0;
			
			index = referenceOrDirectiveValidate(index);
			
			// We should have an in delimiter here.
			if (children.getItemAt(index) is InDelimiter) {
				_delimiter = Node(children.getItemAt(index)).data;
				index++;
			}
			else {
				throw new ValidationError(this, "Method input not supported.");
			}
			
			referenceOrDirectiveValidate(index);
		}
		
		/**
		 *  Validates the method input for what would be expected for an assignment delimiter.
		 */
		public function assignmentDelimiterValidate():void
		{
			var index:int = 0;
			
			index = referenceOrDirectiveValidate(index);
			
			// We should have an assignment delimiter here.
			if (children.getItemAt(index) is AssignmentDelimiter) {
				_delimiter = Node(children.getItemAt(index)).data;
				index++;
			}
			else {
				throw new ValidationError(this, "Method input not supported.");
			}
			
			referenceOrDirectiveOrTextValidate(index);
		}
		
		/**
		 *  Validates the method input for what would be expected for a comparison delimiter.
		 */
		public function comparisonDelimiterValidate():void
		{
			var index:int = 0;
			
			index = referenceOrDirectiveOrTextValidate(index);
			
			// We should have a comparison delimiter here.
			if ((children.getItemAt(index) is LessThanDelimiter)
				|| (children.getItemAt(index) is GreaterThanDelimiter)
				|| (children.getItemAt(index) is LessThanEqualDelimiter)
				|| (children.getItemAt(index) is GreaterThanEqualDelimiter)
				|| (children.getItemAt(index) is EqualsDelimiter)
				|| (children.getItemAt(index) is NotEqualDelimiter)) {
				_delimiter = Node(children.getItemAt(index)).data;
				index++;
			}
			else {
				throw new ValidationError(this, "Method input not supported.");
			}
			
			referenceOrDirectiveOrTextValidate(index);
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function validate():void
		{
			for each (var node:Node in children) {
				// If it's not an expected child, throw error.
				if (!(node is Text) && !(node is DirectiveDelimiter) && !(node is ReferenceDelimiter)
					&& !(node is EscapeDelimiter) && !(node is ParamDelimiter) && !(node is AssignmentDelimiter)
					&& !(node is InDelimiter) && !(node is LessThanDelimiter) && !(node is GreaterThanDelimiter)
					&& !(node is LessThanEqualDelimiter) && !(node is GreaterThanEqualDelimiter)
					&& !(node is EqualsDelimiter) && !(node is NotEqualDelimiter)) {
					throw new ValidationError(this, "Unexpected child found under method input: " + node.data);
				}
				
				node.validate();
			}
		}
	}
}