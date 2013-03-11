package com.pcguild.flexocity.event
{
	import flash.events.Event;
	
	/**
	 *  An event used in tracking Flexocity template generation.
	 */
	public class FlexocityEvent extends Event
	{
		/**
		 *  The event type associated with template generation being complete.
		 */
		public static const TEMPLATE_GENERATED:String = "templateGenerated";
		
		/**
		 *  The event type associated with an error in template generation.
		 */
		public static const TEMPLATE_ERROR:String = "templateError";
		
		private var _data:*;
		
		/**
		 *  Creates a new FlexocityEvent.
		 *
		 * @param type The type of Flexocity event. 
	     * @param data The data associated with this event. For
	     * TEMPLATE_GENERATED events, this will be the template object. For
	     * TEMPLATE_ERROR events, this will be the message of the error.
		 *
		 * @return A reference to a FlexocityEvent object.
		 */
		public function FlexocityEvent(type:String, data:*=null)
		{
			super(type, false, false);
			
			_data = data
		}
		
		/**
		 *  Returns the data associated with this event. For TEMPLATE_GENERATED
		 *  events, this will be the template object. For TEMPLATE_ERROR
		 *  events, this will be the message of the error.
		 */
		public function get data():*
		{
			return _data;
		}
	}
}