package com.pcguild.flexocity
{
	import mx.rpc.Responder;

	public class RPCResponder extends Responder
	{
		public function RPCResponder(result:Function, fault:Function)
		{
			super(result, fault);
		}
	}
}