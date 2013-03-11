package com.pcguild.flexocity.event
{
	import com.pcguild.flexocity.parser.node.Template;
	
	import flash.events.Event;
	
	/**
	 *  An event used internal to Flexocity to track template generation. This
	 *  event is not to be used outside Flexocity. Track using FlexocityEvent.
	 */
	public class TemplateEvent extends Event
	{
		/**
		 *  The event type associated with template parsing being complete.
		 */
		public static const PARSE_COMPLETE:String = "parseComplete";
		
		/**
		 *  The event type associated with template validation being complete.
		 */
		public static const VALIDATION_COMPLETE:String = "validationComplete";
		
		private var _template:Template;
		
		/**
		 *  Creates a new TemplateEvent.
		 *
		 * @param type The type of template event. 
	     * @param template The template being parsed or validated.
		 *
		 * @return A reference to a TemplateEvent object.
		 */
		public function TemplateEvent(type:String, template:Template=null)
		{
			super(type, false, false);
			
			_template = template;
		}
		
		/**
		 *  Returns the template being parsed or validated.
		 *  
		 * @return The template.
		 */
		public function get template():Template
		{
			return _template;
		}
	}
}