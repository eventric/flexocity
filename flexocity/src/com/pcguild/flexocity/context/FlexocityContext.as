package com.pcguild.flexocity.context
{
	import com.pcguild.flexocity.context.ArrayContext;
	import com.pcguild.flexocity.context.Context;
	
	/**
	 *  Implementation of a context, which uses passthroughs to a provided
	 *  context. This also adds the needed initialization of flexocity-specific
	 *  variables in the context.
	 *  
	 * @see com.ericfeminella.collections.HashMap
	 * @see com.pcguild.flexocity.context.Context
	 */
	public class FlexocityContext implements Context
	{
		private var _context:Context;
		
		/**
		 *  Creates a new FlexocityContext.
		 * 
		 * @return A reference to a FlexocityContext object.
		 */
		public function FlexocityContext(context:Context=null)
		{
			// Initialize our context.
			if (context == null) {
				_context = new ArrayContext();
			}
			else {
				_context = context;
			}
			
			init();
		}
		
		/**
		 *  Initializes the context with the flexocity-specific variables.
		 */
		private function init():void
		{
			var directive:Object = new Object();
			var reference:Object = new Object();
			var foreach:Object = new Object();
			var counter:Object = new Object();
			var initial:Object = new Object();
			
			directive["foreach"] = foreach;
			
			reference["unresolved"] = null;
			
			foreach["maxloops"] = -1;
			foreach["counter"] = counter;
			
			counter["name"] = "flexocityCount";
			counter["initial"] = initial;
			
			initial["value"] = 0;
			
			put("directive", directive);
			put("reference", reference);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function put(key:*, value:*):void
		{
			// If it's a string, we want to evaluate it as a chain.
			if (key is String) {
				var tokens:Array = key.split(".");
				var token:String;
				var previousObject:Object = _context.getValue(tokens[0]);
				
				for (var index:int = 1; index < tokens.length - 1; index++) {
					token = tokens[index] as String;
					
					try {
						previousObject = previousObject[token];
					}
					catch (error:Error) {
						previousObject[token] = new Object();
						previousObject = previousObject[token];
					}
				}
				
				// If we actually had a chain, set into the last element.
				if (tokens.length > 1 && previousObject != null) {
					token = tokens[index] as String;
					previousObject[token] = value;
					
					return;
				}
			}
			
			_context.put(key, value);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function getValue(key:*):*
		{
			// If it's a string, we want to evaluate it as a chain.
			if (key is String) {
				var tokens:Array = String(key).split(".");
				var returnObject:Object = _context.getValue(tokens[0]);
				
				for (var index:int = 1; index < tokens.length; index++) {
					var token:String = tokens[index];
					
					try {
						returnObject = returnObject[token];
					}
					catch (error:Error) {
						throw new Error("FlexocityContext.getValue error");
					}
				}
				
				return returnObject;
			}
			
			return _context.getValue(key);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function containsKey(key:*):Boolean
		{
			return _context.containsKey(key);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function getKeys():Array
		{
			return _context.getKeys();
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function remove(key:*):void
		{
			_context.remove(key);
		}
	}
}