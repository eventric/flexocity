package com.pcguild.flexocity.parser.node
{
	import com.pcguild.flexocity.context.Context;
	import com.pcguild.flexocity.error.ContextMergeError;
	import com.pcguild.flexocity.error.ValidationError;
	import com.pcguild.flexocity.parser.Node;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.IndexCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.IndexOpener;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.MethodCloser;
	import com.pcguild.flexocity.parser.node.delimiter.enclosing.MethodOpener;
	import com.pcguild.flexocity.util.ArrayUtil;
	
	import flash.filesystem.FileStream;
	
	/**
	 *  An identifier, which will be a variable, property, or method.
	 *  
	 * @see com.pcguild.flexocity.parser.Node
	 */
	public class Identifier extends Node
	{
		/**
		 *  The lookup key for the previous identifier object. The context
		 *  variable for this key is used to pass the previous identifier
		 *  object between the different identifier evaluate methods.
		 */
		public static const PREVIOUS_IDENTIFIER_OBJECT:String = "previousIdentifierObject";
		
		/**
		 *  The method input for this identifier. This will be null if there is none.
		 */
		private var _methodInput:MethodInput;
		
		/**
		 *  The index input for this identifier. This will be null if there is none.
		 */
		private var _indexInput:IndexInput;
		
		/**
		 *  Creates a new Identifier.
		 * 
		 * @param data The node data.
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
		 * @param parent The parent node for the new node.
		 * 
		 * @return A reference to a Identifier object.
		 */
		public function Identifier(data:String, line:int, column:int, parent:Node=null)
		{
			super(data, line, column, parent);
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function validate():void
		{
			var methodOpenerFound:Boolean = false;
			var indexOpenerFound:Boolean = false;
			var index:int = 0;
			
			// If we have no children, that's okay.
			// This just means it's a normal identifier without a method or index.
			if (children == null) {
				return;
			}
			
			// If we have an opener, set it.
			if (children.length > 1) {
				if (children.getItemAt(index) is MethodOpener) {
					methodOpenerFound = true;
					index++;
				}
				else if (children.getItemAt(index) is IndexOpener) {
					indexOpenerFound = true;
					index++;
				}
			}
			
			// Everything's fine if we have a method input after a method opener.
			if (methodOpenerFound) {
				if (children.getItemAt(index) is MethodInput) {
					_methodInput = children.getItemAt(index) as MethodInput;
					_methodInput.validate();
					index++;
				}
				else {
					throw new ValidationError(this, "Method input not found after method opener.");
				}
			}
			
			// Everything's fine if we have an index input after an index opener.
			if (indexOpenerFound) {
				if (children.getItemAt(index) is IndexInput) {
					_indexInput = children.getItemAt(index) as IndexInput;
					_indexInput.validate();
					index++;
				}
				else {
					throw new ValidationError(this, "Index input not found after index opener.");
				}
			}
			
			// Make sure we have opener/closer pair.
			if (methodOpenerFound && !(children.getItemAt(index) is MethodCloser)) {
				throw new ValidationError(this, "Matching method closer not found for opener.");
			}
			
			// Make sure we have opener/closer pair.
			if (indexOpenerFound && !(children.getItemAt(index) is IndexCloser)) {
				throw new ValidationError(this, "Matching index closer not found for opener.");
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function evaluate(context:Context):*
		{
			var previous:Object;
			var returnObject:Object;
			
			// Set the previous object if there is one in the context.
			if (context.containsKey(PREVIOUS_IDENTIFIER_OBJECT)) {
				previous = context.getValue(PREVIOUS_IDENTIFIER_OBJECT);
			}
			
			// For first identifier in sequence, get object from context lookup.
			if (previous == null) {
				if (!context.containsKey(data)) {
					throw new ContextMergeError(this, "Unable to find identifier in context on lookup: " + data + ".");
				}
				
				returnObject = context.getValue(data);
			}
			// Use the previous object for the lookup.
			else {
				// If we are trying to get the length, give special handling and try to convert to an array first.
				if (data == "length") {
					try {
						previous = ArrayUtil.toArray(previous);
					}
					catch (error:Error) {
						throw new Error("Identifier.evaluate error");
					}
				}
				
				try {
					returnObject = previous[data];
				}
				catch (error:Error) {
					throw new ContextMergeError(this, "Unable to find identifier in object on lookup: " + data + ".");
				}
			}
			
			var value:String = "";
			
			if (_methodInput != null) {
				// We need to handle this.
			}
			
			// If there is index input, we need to evaluate it and use it for an additional lookup.
			if ((_indexInput != null) && (returnObject != null)) {
				var array:Array;
				
				try {
					array = ArrayUtil.toArray(returnObject);
				}
				catch (error:Error) {
					throw new ContextMergeError(this, "Indexed object not a recognized array type: " + returnObject + ".");
				}
				
				value = _indexInput.evaluate(context);
				
				try {
					returnObject = array[value];
				}
				catch (error:Error) {
					throw new ContextMergeError(this, "Unable to find index in object on lookup: " + value + ".");
				}
			}
			
			if (returnObject != null) {
				context.put(PREVIOUS_IDENTIFIER_OBJECT, returnObject);
			}
			
			return returnObject;
		}
		
		/**
		 * {@inheritDoc}
		 */
		override public function merge(context:Context, fileStream:FileStream):void
		{
			fileStream.writeUTFBytes(toString());
		}
	}
}