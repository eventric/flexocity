package com.pcguild.flexocity.parser
{
	import com.pcguild.flexocity.context.Context;
	
	import flash.filesystem.FileStream;
	
	import mx.collections.ArrayCollection;
	
	/**
	 *  A node in the parsed tree.
	 */
	public class Node
	{
		/**
		 *  Data string of the node.
		 */
		private var _data:String;
		
		private var _line:int;
		private var _column:int;
		
		/**
		 *  The parent node of this node.
		 */
		private var _parent:Node;
		
		/**
		 *  The child nodes of this node.
		 */
		private var _children:ArrayCollection;
		
		/**
		 *  Creates a new Node. This will also add this as a child of the
		 *  parent.
		 *
		 * @param data The data for this node.
		 * @param line The line this node was read from.
		 * @param column The column this node was read from.
	     * @param parent The parent of this node.
		 *
		 * @return A reference to a Node object.
		 */
		public function Node(data:String, line:int, column:int, parent:Node=null)
		{
			_data = data;
			_line = line;
			_column = column;
			_parent = parent;
			
			if (parent != null) {
				parent.addChild(this);
			}
		}
		
		/**
		 *  Returns the data string for this node.
		 *
		 * @return The data string.
		 */
		public function get data():String
		{
			return _data;
		}
		
		/**
		 *  Returns the line number for this node.
		 *
		 * @return The line number.
		 */
		public function get line():int
		{
			return _line;
		}
		
		/**
		 *  Returns the column number for this node.
		 *
		 * @return The column number.
		 */
		public function get column():int
		{
			return _column;
		}
		
		/**
		 *  Returns the parent of this node.
		 *
		 * @return The parent node.
		 */
		public function get parent():Node
		{
			return _parent;
		}
		
		/**
		 *  Returns the children of this node.
		 *
		 * @return The children array collection.
		 */
		public function get children():ArrayCollection
		{
			return _children;
		}
		
		/**
		 *  Adds the given node as a child of this node. It also sets this as
		 *  a parent of the child node.
		 *
		 * @param child The child node.
		 */
		public function addChild(child:Node):void
		{
			if (_children == null) {
				_children = new ArrayCollection();
			}
			
			_children.addItem(child);
			child._parent = this;
		}
		
		/**
		 *  Removes the given child node from this node. It also nulls out the
		 *  parent of the child node.
		 *
		 * @param child The child node.
		 */
		public function removeChild(child:Node):void
		{
			if (_children == null) {
				return;
			}
			
			_children.removeItemAt(_children.getItemIndex(child));
			child._parent = null;
		}
		
		/**
		 *  Returns a string representation of this node.
		 *
		 * @return The string representation of this node.
		 */
		public function toString():String
		{
			var output:String = data;
			
			for each (var node:Node in children) {
				output += node.toString();
			}
			
			return output;
		}
		
		/**
		 *  Validates the node structure. This should be overridden in
		 *  extending classes with specific validation checks.
		 * 
		 * @throws ValidationError if an error occurs in node validation
		 */
		public function validate():void
		{
			for each (var node:Node in children) {
				node.validate();
			}
		}
		
		/**
	     *  Returns the evaluation of this node, which depends on the context.
	     *  This should be overridden in extending classes with any specific
	     *  evaluation.
	     *
	     * @param context The context to evaluate in.
	     * @return     The value.
	     * @throws ContextMergeError if an error occurs in the evaluation
	     */
		public function evaluate(context:Context):*
		{
			var value:String = _data;
			
			for each (var node:Node in children) {
				value += node.evaluate(context);
			}
			
			return value;
		}
		
		/**
	     *  Merges the context with the values of the node structure. The
	     *  result is written to the file stream. This should be overridden
	     *  in extending classes with any specific merging.
	     *
	     * @param context The context to evaluate in.
	     * @param fileStream The file stream to write to.
	     * @throws ContextMergeError if an error occurs in the merge
	     */
		public function merge(context:Context, fileStream:FileStream):void
		{
			fileStream.writeUTFBytes(_data);
			
			for each (var node:Node in children) {
				node.merge(context, fileStream);
			}
		}
	}
}