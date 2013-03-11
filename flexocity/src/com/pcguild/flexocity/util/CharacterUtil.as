package com.pcguild.flexocity.util
{
	import mx.collections.ArrayCollection;
	
	/**
	 *  Utility for character functions.
	 */
	public class CharacterUtil
	{
		private static var lowerCaseChars:ArrayCollection = new ArrayCollection([
			"a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m",
			"n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"
		]);
		private static var upperCaseChars:ArrayCollection = new ArrayCollection([
			"A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M",
			"N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"
		]);
		private static var numericChars:ArrayCollection = new ArrayCollection([
			"0", "1", "2", "3", "4", "5", "6", "7", "8", "9"
		]);
		
		/**
		 *  Returns whether the given character is lower case.
		 *  
		 * @param char The character.
		 * 
		 * @return Whether the character is lower case.
		 */
		public static function isLowerCase(char:String):Boolean
		{
			return lowerCaseChars.contains(char);
		}
		
		/**
		 *  Returns whether the given character is upper case.
		 *  
		 * @param char The character.
		 * 
		 * @return Whether the character is upper case.
		 */
		public static function isUpperCase(char:String):Boolean
		{
			return upperCaseChars.contains(char);
		}
		
		/**
		 *  Returns whether the given character is alphabetic case.
		 *  
		 * @param char The character.
		 * 
		 * @return Whether the character is alphabetic case.
		 */
		public static function isAlphabetic(char:String):Boolean
		{
			return lowerCaseChars.contains(char) || upperCaseChars.contains(char);
		}
		
		/**
		 *  Returns whether the given character is numeric case.
		 *  
		 * @param char The character.
		 * 
		 * @return Whether the character is numeric case.
		 */
		public static function isNumeric(char:String):Boolean
		{
			return numericChars.contains(char);
		}
	}
}