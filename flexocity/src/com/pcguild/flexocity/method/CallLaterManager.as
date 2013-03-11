package com.pcguild.flexocity.method
{
	import mx.core.UIComponent;
	
	/**
	 *  A manager class for keeping track of what methods to call later, what
	 *  callback to call after the method calls, and how often callLater should
	 *  be used to allow UI updates.
	 */
	public class CallLaterManager
	{
		private var _component:UIComponent;
		private var _callsBeforeCallLater:int;
		private var _methodQueue:Array = new Array();
		private var _callbackStack:Array = new Array();
		private var _processing:Boolean = false;
		private var _stopping:Boolean = false;
		private var _callCount:int = 0;
		
		/**
		 *  Creates a new CallLaterManager.
		 *
		 * @param component The UI component used for callLater calls. 
	     * @param callsBeforeCallLater The number of method calls which will
	     * occur before callLater is used. This defaults to 20.
		 *
		 * @return A reference to a CallLaterManager object.
		 */
		public function CallLaterManager(component:UIComponent, callsBeforeCallLater:int=20)
		{
			_component = component;
			_callsBeforeCallLater = callsBeforeCallLater;
		}
		
		/**
		 *  This handles when a call is finished. It tries to call anything on
		 *  the method queue first, then anything on the callback stack. It
		 *  also makes sure to use callLater when it's preferred.
		 */
		private function callComplete():void
		{
			var callLater:Boolean = false;
			
			// We only want to callLater if we've already done the appropriate number of calls.
			if (_callCount < _callsBeforeCallLater) {
				_callCount++;
			}
			else {
				_callCount = 0;
				callLater = true;
			}
			
			_processing = true;
			
			// If we're in the middle of stopping, we don't want to do this.
			if (!_stopping) {
				// Handle any methods first.
				if (_methodQueue.length > 0) {
					var method:Method;
					
					_methodQueue = _methodQueue.reverse();
					method = _methodQueue.pop() as Method;
					_methodQueue = _methodQueue.reverse();
					
					// If we had a timeout and should use call later, do so.
					if (callLater) {
						_component.callLater(method.method, method.args);
						_component.callLater(callComplete);
					}
					// Else we just want to call the method normally.
					else {
						method.method.apply(NaN, method.args);
						callComplete();
					}
				}
				// Handle any callbacks second.
				else if (_callbackStack.length > 0) {
					var callback:MethodCallback = _callbackStack.pop() as MethodCallback;
					
					// If we had a timeout and should use call later, do so.
					if (callLater) {
						_component.callLater(callback.method, [ callback ]);
						_component.callLater(callComplete);
					}
					// Else we just want to call the method normally.
					else {
						callback.method(callback);
						callComplete();
					}
				}
				// If no methods or callbacks, we're stopping.
				else {
					_stopping = true;
				}
			}
			
			if (_stopping) {
				_processing = false;
				_stopping = false;
			}
		}
		
		/**
		 *  Adds the method to the queue for being called later.
		 *  
		 * @param method The method function.
		 * @param args The method arguments.
		 * @param callback The method callback.
		 */
		public function callLater(method:Function, args:Array=null, callback:MethodCallback=null):void
		{
			if (!_stopping) {
				_methodQueue.push(new Method(method, args));
				
				if (callback) {
					_callbackStack.push(callback);
				}
				
				// If we aren't in the middle of processing calls or callbacks, start the queue.
				if (!_processing) {
					callComplete();
				}
			}
		}
		
		/**
		 *  Clears out the method queue and the callback stack. Any methods
		 *  added after this clear before getting back to callComplete will be
		 *  lost.
		 */
		public function clear():void
		{
			_methodQueue = new Array();
			_callbackStack = new Array();
			
			if (_processing) {
				_stopping = true;
			}
		}
		
		/**
		 *  Sets the given error code into the next callback on the stack so it
		 *  will know there was an error.
		 *  
		 * @param The error code.
		 */
		public function setErrorCode(errorCode:int):void
		{
			// If there are callbacks, set the errorCode for the last one.
			if (_callbackStack.length > 0) {
				var callback:MethodCallback = _callbackStack[_callbackStack.length - 1] as MethodCallback;
				
				callback.errorCode = errorCode;
			}
		}
	}
}