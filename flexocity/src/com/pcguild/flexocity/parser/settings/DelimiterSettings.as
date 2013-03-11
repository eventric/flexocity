package com.pcguild.flexocity.parser.settings
{
	/**
	 *  Delimiter settings interface.
	 */
	public interface DelimiterSettings
	{
		// Other delimiters.
		/**
		 *  Returns the block comment delimiter. This is the instruction for a
		 *  block comment to begin and end.
		 * 
		 * @return Delimiter value.
		 */
		function get blockComment():String;
		
		/**
		 *  Returns the end of line delimiter. This is used for things like
		 *  knowing where a line comment ends.
		 * 
		 * @return Delimiter value.
		 */
		function get endOfLine():String;
		
		/**
		 *  Returns the single quote delimiter. This is used for things like
		 *  specifying string values.
		 * 
		 * @return Delimiter value.
		 */
		function get singleQuote():String;
		
		/**
		 *  Returns the double quote delimiter. This is used for things like
		 *  specifying string values.
		 * 
		 * @return Delimiter value.
		 */
		function get doubleQuote():String;
		
		// Normal delimiters.
		/**
		 *  Returns the assignment delimiter. This is used for things like the
		 *  set instruction.
		 * 
		 * @return Delimiter value.
		 */
		function get assignment():String;
		
		/**
		 *  Returns the directive delimiter. This signals the start of an
		 *  instruction which is to be executed.
		 * 
		 * @return Delimiter value.
		 */
		function get directive():String;
		
		/**
		 *  Returns the escape delimiter. This is used to escape directives and
		 *  references.
		 * 
		 * @return Delimiter value.
		 */
		function get escape():String;
		
		/**
		 *  Returns the in delimiter. This is used for things like the foreach
		 *  instruction.
		 * 
		 * @return Delimiter value.
		 */
		function get inDelimiter():String;
		
		/**
		 *  Returns the param delimiter. This is used to separate method
		 *  arguments.
		 * 
		 * @return Delimiter value.
		 */
		function get param():String;
		
		/**
		 *  Returns the reference delimiter. This signals the start of an
		 *  identifier which is to be evaluated.
		 * 
		 * @return Delimiter value.
		 */
		function get reference():String;
		
		/**
		 *  Returns the sequence delimiter. This is used in identifier chains to
		 *  separate the identifiers.
		 * 
		 * @return Delimiter value.
		 */
		function get sequence():String;
		
		// Enclosing delimiters.
		/**
		 *  Returns the formal opener delimiter. This marks an identifier or
		 *  instruction as formal, which means they are ended by a formal
		 *  closer.
		 * 
		 * @return Delimiter value.
		 */
		function get formalOpener():String;
		
		/**
		 *  Returns the formal closer delimiter. This ends a formal identifier
		 *  or instruction.
		 * 
		 * @return Delimiter value.
		 */
		function get formalCloser():String;
		
		/**
		 *  Returns the index opener delimiter. This starts an index for an
		 *  identifier.
		 * 
		 * @return Delimiter value.
		 */
		function get indexOpener():String;
		
		/**
		 *  Returns the index closer delimiter. This ends an index for an
		 *  identifier.
		 * 
		 * @return Delimiter value.
		 */
		function get indexCloser():String;
		
		/**
		 *  Returns the method opener delimiter. This starts a method for an
		 *  identifier or instruction.
		 * 
		 * @return Delimiter value.
		 */
		function get methodOpener():String;
		
		/**
		 *  Returns the method closer delimiter. This ends a method for an
		 *  identifier or instruction.
		 * 
		 * @return Delimiter value.
		 */
		function get methodCloser():String;
		
		// Logic delimiters.
		/**
		 *  Returns the equals delimiter. This signals comparison, whether the
		 *  surrounding values are equal.
		 * 
		 * @return Delimiter value.
		 */
		function get equals():String;
		
		/**
		 *  Returns the not equal delimiter. This signals comparison, whether the
		 *  surrounding values are not equal.
		 * 
		 * @return Delimiter value.
		 */
		function get notEqual():String;
		
		/**
		 *  Returns the greater than delimiter. This signals comparison,
		 *  whether the left value is greater than the right value.
		 * 
		 * @return Delimiter value.
		 */
		function get greaterThan():String;
		
		/**
		 *  Returns the greater than equals delimiter. This signals comparison,
		 *  whether the left value is greater than or equal to the right value.
		 * 
		 * @return Delimiter value.
		 */
		function get greaterThanEquals():String;
		
		/**
		 *  Returns the less than delimiter. This signals comparison, whether
		 *  the left value is less than the right value.
		 * 
		 * @return Delimiter value.
		 */
		function get lessThan():String;
		
		/**
		 *  Returns the less than equals delimiter. This signals comparison,
		 *  whether the left value is less than or equal to the right value.
		 * 
		 * @return Delimiter value.
		 */
		function get lessThanEquals():String;
		
		// Shorthand settings.
		/**
		 *  Returns whether to allow shorthand identifiers.
		 * 
		 * @return Whether to disable shorthand identifiers.
		 */
		function get shorthandIdentifiersDisabled():Boolean;
		
		/**
		 *  Returns whether to allow shorthand instructions.
		 * 
		 * @return Whether to disable shorthand instruction.
		 */
		function get shorthandInstructionsDisabled():Boolean;
	}
}