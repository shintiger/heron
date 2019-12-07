package com.gigateam.worker 
{
	import com.gigateam.world.physics.TestTemplate;
	import com.gigateam.world.physics.shape.AABB;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.system.WorkerState;
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Tiger
	 */
	public class WorkerLobby extends EventDispatcher
	{
		[Embed(source="Lobby.swf", mimeType="application/octet-stream")]
        private static var BackgroundWorker_ByteClass:Class;
		
		private var disposed:Boolean = false;
		private var worker:Worker;
		private var outputChannel:MessageChannel;
		private var inputChannel:MessageChannel;
		public function WorkerLobby() 
		{
			init();
		}
		private static function get workerBytes():ByteArray{
			return new BackgroundWorker_ByteClass();
		}
		private function init():void{
			worker = WorkerDomain.current.createWorker(workerBytes, true);
			outputChannel = Worker.current.createMessageChannel(worker);
			worker.setSharedProperty(WorkerMain.MASTER_OUTPUT, outputChannel);
			
			inputChannel = worker.createMessageChannel(Worker.current);
			worker.setSharedProperty(WorkerMain.MASTER_INPUT, inputChannel);
			inputChannel.addEventListener(Event.CHANNEL_MESSAGE, onMessage);
			
			worker.addEventListener(Event.WORKER_STATE, onStateChanged);
			worker.start();
		}
		private function onStateChanged(e:Event):void{
			dispatchEvent(new Event(worker.state));
		}
		private function onMessage(e:Event):void{
			if (!inputChannel.messageAvailable){
				return;
			}
			var msg:ByteArray = inputChannel.receive(true) as ByteArray;
			if (msg == null){
				return;
			}
			var signal:WorkerSignal = WorkerSignal.parse(msg);
			var evt:SignalEvent = new SignalEvent(signal);
			dispatchEvent(evt);
			if (signal.command == WorkerSignal.DISPOSE){
				realDispose();
			}
		}
		public function connect(host:String, port:uint):void{
			if (disposed){
				return;
			}
			var signal:WorkerSignal = new WorkerSignal(WorkerSignal.CONNECT);
			signal.writeString(host);
			signal.writeInteger(port);
			outputChannel.send(signal.compose());
		}
		public function send(by:ByteArray):void{
			if (disposed){
				return;
			}
			var signal:WorkerSignal = new WorkerSignal(WorkerSignal.DATA);
			signal.stream.writeShort(by.length);
			signal.stream.writeBytes(by, 0, by.length);
			outputChannel.send(signal.compose());
		}
		public function close():void{
			if (disposed){
				return;
			}
			var signal:WorkerSignal = new WorkerSignal(WorkerSignal.CLOSED);
			outputChannel.send(signal.compose());
		}
		public function dispose():void{
			if (disposed){
				return;
			}
			close();
			
			disposed = true;
		}
		private function realDispose():void{
			inputChannel.removeEventListener(Event.CHANNEL_MESSAGE, onMessage);
			inputChannel.close();
			outputChannel.close();
			worker.removeEventListener(Event.WORKER_STATE, onStateChanged);
			worker.terminate();
			worker = null;
		}
	}

}