package com.pcguild.flexocity
{
	import com.pcguild.flexocity.event.FlexocityEvent;
	import com.pcguild.flexocity.event.TemplateEvent;
	import com.pcguild.flexocity.parser.Parser;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	import mx.core.UIComponent;
	
	/**
	 *  Flexocity provides template parsing.
	 */
	public class Flexocity extends EventDispatcher
	{
		private static var _flexocity:Flexocity;
		
		private var _fileStream:FileStream = null;
		
		/**
		 *  Singleton getter method. This should be used by the static methods
		 *  in this class.
		 *  
		 * @return The Flexocity instance.
		 */
		private static function get flexocity():Flexocity
		{
			if (_flexocity == null) {
				_flexocity = new Flexocity();
				
				_flexocity.addEventListener(TemplateEvent.PARSE_COMPLETE, _flexocity.parseComplete);
				_flexocity.addEventListener(FlexocityEvent.TEMPLATE_ERROR, _flexocity.templateError);
			}
			
			return _flexocity;
		}
		
		/**
		 * {@inheritDoc}
		 */
		public static function addEventListener(type:String, listener:Function):void
		{
			flexocity.addEventListener(type, listener);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public static function dispatchEvent(event:Event):Boolean
		{
			return flexocity.dispatchEvent(event);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public static function hasEventListener(type:String):Boolean
		{
			return flexocity.hasEventListener(type);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public static function removeEventListener(type:String, listener:Function):void
		{
			flexocity.removeEventListener(type, listener);
		}
		
		/**
		 * {@inheritDoc}
		 */
		public static function willTrigger(type:String):Boolean
		{
			return flexocity.willTrigger(type);
		}
		
		/**
	     *  Initiates the parsing of the given template file. To get the
	     *  template when parsing is complete, you should add a listener on
	     *  Flexocity for FlexocityEvent.TEMPLATE_GENERATED. It is also a good
	     *  idea to do the same for FlexocityEvent.TEMPLATE_ERROR.
	     *
	     * @param filename The file name of the desired template.
	     * @param parent The parent UIComponent used for UI updates.
	     * @throws Error If template is being generated already.
	     */
		public static function generateTemplate(filename:String, parent:UIComponent):void
		{
			// Throw error if template is already being generated.
			if (flexocity._fileStream != null) {
				throw new Error("Concurrent template generation is not supported.");
			}
			
			flexocity._fileStream = new FileStream();
			
			var file:File = new File(filename);
			var parser:Parser = new Parser(flexocity._fileStream, parent);
			
			flexocity._fileStream.open(file, FileMode.READ);
			
			// callLater so that we're sure to return directly to the caller of
			// this method.
			parent.callLater(parser.parse);
		}
		
		/**
		 *  Handles when template parsing is complete, closing the file stream
		 *  and validating the template.
		 *  
		 * @param event The template event.
		 */
		private function parseComplete(event:TemplateEvent):void
		{
			if( _fileStream != null )
			{
				_fileStream.close();
				_fileStream = null;
			}
			
			try {
				event.template.validate();
				
				dispatchEvent(new FlexocityEvent(FlexocityEvent.TEMPLATE_GENERATED, event.template));
			}
			catch (error:Error) {
				dispatchEvent(new FlexocityEvent(FlexocityEvent.TEMPLATE_ERROR, error.message));
			}
		}
		
		public static function get fileStream():FileStream
		{
			return flexocity._fileStream;
		}
		
		/**
		 *  Handles when there is a Flexocity error.
		 *  
		 * @param event The Flexocity event.
		 */
		private function templateError(event:FlexocityEvent):void
		{
			// If the file stream is still open, we need to close it.
			if (_fileStream != null) {
				_fileStream.close();
				_fileStream = null;
			}
			
			trace(event.data);
		}
	}
}