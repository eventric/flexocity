package com.pcguild.flexocity.context
{
	/**
	 *  Interface describing the application data context.  This is used
	 *  for storage of the data which gets merged into the templates.
	 */
	public interface Context
	{
		/**
	     *  Adds a name/value pair to the context.
	     *
	     * @param key   The name to key the provided value with.
	     * @param value The corresponding value.
	     */
		function put(key:*, value:*):void;
		
		/**
	     *  Gets the value corresponding to the provided key from the context.
	     *
	     * @param key The name of the desired value.
	     * @return    The value corresponding to the provided key.
	     */
		function getValue(key:*):*;
		
		/**
	     *  Indicates whether the specified key is in the context.
	     *
	     * @param key The key to look for.
	     * @return    Whether the key is in the context.
	     */
		function containsKey(key:*):Boolean;
		
		/**
	     *  Get all the keys for the values in the context.
	     * 
	     * @return All the keys for the values in the context.
	     */
		function getKeys():Array;
		
		/**
	     *  Removes the value associated with the specified key from the context.
	     *
	     * @param key The name of the value to remove.
	     */
		function remove(key:*):void;
	}
}