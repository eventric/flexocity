package com.pcguild.flexocity.parser.settings
{
	/**
	 *  Default delimiter settings.
	 *  
	 * @see com.pcguild.flexocity.parser.settings.DelimiterSettings
	 */
	public class DefaultDelimiterSettings implements DelimiterSettings
	{
		// Other delimiters.
		private var _blockComment:String = "*";
		private var _endOfLine:String = "\n";
		private var _singleQuote:String = "\'";
		private var _doubleQuote:String = "\"";
		
		// Normal delimiters.
		private var _assignment:String = "=";
		private var _directive:String = "#";
		private var _escape:String = "\\"; // This must be a sequence of backslashes.
		private var _inDelimiter:String = " in ";
		private var _param:String = ",";
		private var _reference:String = "$";
		private var _sequence:String = ".";
		
		// Enclosing delimiters.
		private var _formalOpener:String = "{";
		private var _formalCloser:String = "}";
		private var _indexOpener:String = "[";
		private var _indexCloser:String = "]";
		private var _methodOpener:String = "(";
		private var _methodCloser:String = ")";
		
		// Logic delimiters.
		private var _equals:String = "==";
		private var _notEqual:String = "!=";
		private var _greaterThan:String = ">";
		private var _greaterThanEquals:String = ">=";
		private var _lessThan:String = "<";
		private var _lessThanEquals:String = "<=";
		
		// Shorthand settings.
		private var _shorthandIdentifiersDisabled:Boolean = false;
		private var _shorthandInstructionsDisabled:Boolean = false;
		
		/**
		 *  Creates a new DefaultDelimiterSettings.
		 * 
		 * @param overrideSettings Any override values for the new settings.
		 * 
		 * @return A reference to a DefaultDelimiterSettings object.
		 */
		public function DefaultDelimiterSettings(overrideSettings:Object=null)
		{
			if (overrideSettings != null) {
				if (overrideSettings.hasOwnProperty("blockComment")) {
					_blockComment = overrideSettings["blockComment"];
				}
				
				if (overrideSettings.hasOwnProperty("endOfLine")) {
					_endOfLine = overrideSettings["endOfLine"];
				}
				
				if (overrideSettings.hasOwnProperty("singleQuote")) {
					_singleQuote = overrideSettings["singleQuote"];
				}
				
				if (overrideSettings.hasOwnProperty("doubleQuote")) {
					_singleQuote = overrideSettings["doubleQuote"];
				}
				
				if (overrideSettings.hasOwnProperty("assignment")) {
					_assignment = overrideSettings["assignment"];
				}
				
				if (overrideSettings.hasOwnProperty("directive")) {
					_directive = overrideSettings["directive"];
				}
				
				if (overrideSettings.hasOwnProperty("escape")) {
					_escape = overrideSettings["escape"];
				}
				
				if (overrideSettings.hasOwnProperty("inDelimiter")) {
					_inDelimiter = overrideSettings["inDelimiter"];
				}
				
				if (overrideSettings.hasOwnProperty("reference")) {
					_reference = overrideSettings["reference"];
				}
				
				if (overrideSettings.hasOwnProperty("sequence")) {
					_sequence = overrideSettings["sequence"];
				}
				
				if (overrideSettings.hasOwnProperty("formalOpener")) {
					_formalOpener = overrideSettings["formalOpener"];
				}
				
				if (overrideSettings.hasOwnProperty("formalCloser")) {
					_formalCloser = overrideSettings["formalCloser"];
				}
				
				if (overrideSettings.hasOwnProperty("indexOpener")) {
					_indexOpener = overrideSettings["indexOpener"];
				}
				
				if (overrideSettings.hasOwnProperty("indexCloser")) {
					_indexCloser = overrideSettings["indexCloser"];
				}
				
				if (overrideSettings.hasOwnProperty("methodOpener")) {
					_methodOpener = overrideSettings["methodOpener"];
				}
				
				if (overrideSettings.hasOwnProperty("methodCloser")) {
					_methodCloser = overrideSettings["methodCloser"];
				}
				
				if (overrideSettings.hasOwnProperty("equals")) {
					_equals = overrideSettings["equals"];
				}
				
				if (overrideSettings.hasOwnProperty("notEqual")) {
					_notEqual = overrideSettings["notEqual"];
				}
				
				if (overrideSettings.hasOwnProperty("greaterThan")) {
					_greaterThan = overrideSettings["greaterThan"];
				}
				
				if (overrideSettings.hasOwnProperty("greaterThanEquals")) {
					_greaterThanEquals = overrideSettings["greaterThanEquals"];
				}
				
				if (overrideSettings.hasOwnProperty("lessThan")) {
					_lessThan = overrideSettings["lessThan"];
				}
				
				if (overrideSettings.hasOwnProperty("lessThanEquals")) {
					_lessThanEquals = overrideSettings["lessThanEquals"];
				}
				
				if (overrideSettings.hasOwnProperty("disableShorthandIdentifiers")) {
					_shorthandIdentifiersDisabled = overrideSettings["disableShorthandIdentifiers"];
				}
				
				if (overrideSettings.hasOwnProperty("disableShorthandInstructions")) {
					_shorthandInstructionsDisabled = overrideSettings["disableShorthandInstructions"];
				}
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get blockComment():String
		{
			return _blockComment;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get endOfLine():String
		{
			return _endOfLine;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get singleQuote():String
		{
			return _singleQuote;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get doubleQuote():String
		{
			return _doubleQuote;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get assignment():String
		{
			return _assignment;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get directive():String
		{
			if (_shorthandInstructionsDisabled) {
				return _directive + _formalOpener;
			}
			else {
				return _directive;
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get escape():String
		{
			return _escape;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get inDelimiter():String
		{
			return _inDelimiter;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get param():String
		{
			return _param;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get reference():String
		{
			if (_shorthandIdentifiersDisabled) {
				return _reference + _formalOpener;
			}
			else {
				return _reference;
			}
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get sequence():String
		{
			return _sequence;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get formalOpener():String
		{
			return _formalOpener;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get formalCloser():String
		{
			return _formalCloser;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get indexOpener():String
		{
			return _indexOpener;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get indexCloser():String
		{
			return _indexCloser;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get methodOpener():String
		{
			return _methodOpener;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get methodCloser():String
		{
			return _methodCloser;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get equals():String
		{
			return _equals;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get notEqual():String
		{
			return _notEqual;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get greaterThan():String
		{
			return _greaterThan;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get greaterThanEquals():String
		{
			return _greaterThanEquals;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get lessThan():String
		{
			return _lessThan;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get lessThanEquals():String
		{
			return _lessThanEquals;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get shorthandIdentifiersDisabled():Boolean
		{
			return _shorthandIdentifiersDisabled
		}
		
		/**
		 * {@inheritDoc}
		 */
		public function get shorthandInstructionsDisabled():Boolean
		{
			return _shorthandInstructionsDisabled
		}
	}
}