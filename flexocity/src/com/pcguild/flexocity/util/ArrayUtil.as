package com.pcguild.flexocity.util
{
	import mx.collections.ArrayCollection;
	
	/**
	 *  Utility for array functions.
	 */
	public class ArrayUtil
	{
		/**
		 *  Converts the given object into an array. If the object is an
		 *  unknown type, an error is thrown.
		 *  
		 * @param object The object to convert.
		 * 
		 * @return The array.
		 */
		public static function toArray(object:*):Array
		{
			if (object == null) {
				return new Array();
			}
			else if (object is Array) {
				return object;
			}
			else if (object is ArrayCollection) {
				return object.source;
			}
			else if (object is XMLList) {
				var resultArray:Array = new Array();
				var itemXMLList:XMLList = object.item;
				
				for each (var i:XML in itemXMLList) {
					resultArray.push(i);
				}
				
				return resultArray;
			}
			else {
				throw new Error("Unknown data type for iteration.");
			}
		}
	}
}