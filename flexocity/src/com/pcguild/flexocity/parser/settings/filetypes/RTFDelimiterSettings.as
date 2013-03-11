package com.pcguild.flexocity.parser.settings.filetypes
{
	import com.pcguild.flexocity.parser.settings.DefaultDelimiterSettings;
	
	/**
	 *  RTF specific delimiter settings.
	 *  
	 * @see com.pcguild.flexocity.parser.settings.DefaultDelimiterSettings
	 */
	public class RTFDelimiterSettings extends DefaultDelimiterSettings
	{
		/**
		 *  Creates a new RTFDelimiterSettings.
		 * 
		 * @param overrideSettings Any override values for the new settings.
		 * 
		 * @return A reference to a RTFDelimiterSettings object.
		 */
		public function RTFDelimiterSettings(overrideSettings:Object=null)
		{
			overrideSettings["escape"] = "\\\\";
			overrideSettings["formalOpener"] = "\\{";
			overrideSettings["formalCloser"] = "\\}";
			overrideSettings["endOfLine"] = "\\\n";
			
			super(overrideSettings);
		}
	}
}