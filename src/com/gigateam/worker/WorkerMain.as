package com.gigateam.worker 
{
	import com.gigateam.velcro.VelcroClient;
	import com.gigateam.velcro.events.ConnectionEvent;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Tiger
	 */
	public class WorkerMain extends Sprite
	{
		public static const MASTER_OUTPUT:String = "masterOutput";
		public static const MASTER_INPUT:String = "masterInput";
		private var masterOutput:MessageChannel;
		private var masterInput:MessageChannel;
		
		private var connection:VelcroClient;
		public function WorkerMain() 
		{
			if(Worker.isSupported && !Worker.current.isPrimordial){
				init();
			}
		}
		private function init():void{
			masterOutput = Worker.current.getSharedProperty(MASTER_OUTPUT) as MessageChannel;
			masterOutput.addEventListener(Event.CHANNEL_MESSAGE, onMessage);
			masterInput = Worker.current.getSharedProperty(MASTER_INPUT) as MessageChannel;
		}
		private function onMessage(e:Event):void{
			if (!masterOutput.messageAvailable){
				return;
			}
			var msg:ByteArray = masterOutput.receive(true) as ByteArray;
			if (msg == null){
				return;
			}
			var signal:WorkerSignal = WorkerSignal.parse(msg);
			var outSignal:WorkerSignal;
			switch(signal.command){
				case WorkerSignal.CONNECT:
					initConnection(WorkerSignal.FIXED_KEY);
					connection.connect(signal.host, signal.port);
					break;
				case WorkerSignal.DATA:
					if (!connection.connected){
						break;
					}
					connection.send(signal.payload);
					break;
				case WorkerSignal.CLOSED:
					dispose();
					break;
			}
		}
		private function onData(e:ConnectionEvent):void{
			var outSignal:WorkerSignal;
			outSignal = new WorkerSignal(WorkerSignal.DATA);
			outSignal.stream.writeUnsignedInt(connection.getLastRTT());
			outSignal.stream.writeShort(e.data.bytesAvailable);
			outSignal.stream.writeBytes(e.data, 0, e.data.bytesAvailable);
			
			masterInput.send(outSignal.compose());
		}
		private function onConnected(e:ConnectionEvent):void{
			var outSignal:WorkerSignal;
			outSignal = new WorkerSignal(WorkerSignal.CONNECTED);
			outSignal.writeString(connection.host);
			outSignal.writeInteger(connection.localPort);
			
			masterInput.send(outSignal.compose());
		}
		private function onDisconnected(e:ConnectionEvent):void{
			var outSignal:WorkerSignal;
			outSignal = new WorkerSignal(WorkerSignal.CLOSED);
			outSignal.writeString(connection.host);
			outSignal.writeInteger(connection.port);
			
			masterInput.send(outSignal.compose());
			
			//dispose();
		}
		private function initConnection(key:String):void{
			connection = new VelcroClient(key);
			connection.addEventListener(ConnectionEvent.CONNECTED, onConnected);
			connection.addEventListener(ConnectionEvent.CONNECTION_CLOSED, onDisconnected);
			connection.addEventListener(ConnectionEvent.DATA, onData);
		}
		private function dispose():void{
			connection.close();
			
			connection.removeEventListener(ConnectionEvent.CONNECTED, onConnected);
			connection.removeEventListener(ConnectionEvent.CONNECTION_CLOSED, onDisconnected);
			connection.removeEventListener(ConnectionEvent.DATA, onData);
			connection = null;
			
			var outSignal:WorkerSignal;
			outSignal = new WorkerSignal(WorkerSignal.DISPOSE);
			masterInput.send(outSignal.compose());
		}
	}

}