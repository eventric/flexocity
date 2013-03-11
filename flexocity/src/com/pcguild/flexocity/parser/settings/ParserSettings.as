package com.pcguild.flexocity.parser.settings
{
	/**
	 *  Parser settings, which include the delimiter settings.
	 *  
	 * @see com.pcguild.flexocity.parser.settings.DelimiterSettings
	 */
	public class ParserSettings
	{
		private static var _parserSettings : ParserSettings;
		private var _delimiterSettings:DelimiterSettings;
		
		/**
		 *  Returns the delimiter settings.
		 * 
		 * @return The DelimiterSettings object.
		 */
		public function get delimiterSettings():DelimiterSettings
		{
			return _delimiterSettings;
		}
		
		/**
		 *  Creates a new ParserSettings and initialized it with the delimitier
		 *  settings. This can only be called once.
		 *  
		 * @param settings Delimiter settings used to initialize.
		 */
		public static function init(settings:DelimiterSettings):void
		{
			if( _parserSettings == null )
				_parserSettings = new ParserSettings();
	
			_parserSettings._delimiterSettings = settings;
		}
		
		/**
		 *  Returns the static instance of the ParserSettings. If not
		 *  initialize, this will do so.
		 * 
		 * @return The reference to the ParserSettings object.
		 */
		public static function getInstance() : ParserSettings 
		{
			if ( _parserSettings == null )
			{
				_parserSettings = new ParserSettings();
				_parserSettings._delimiterSettings = new DefaultDelimiterSettings();
			}
				
			return _parserSettings;
		}

		/**
		 *  Creates a new ParserSettings. This should not be called outside of
		 *  this class. Use getInstance().
		 * 
		 * @return A reference to a ParserSettings object.
		 */
		public function ParserSettings() 
		{
			if ( _parserSettings != null )
				throw new Error( "ParserSettings is already instantiated - use getInstance" );	
		}
	}
}