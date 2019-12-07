package com.gigateam.worker 
{
	import flash.utils.ByteArray;
	import flash.utils.getTimer;
	/**
	 * ...
	 * @author Tiger
	 */
	public class WorkerSignal 
	{
		public static var FIXED_KEY:String = "1234";
		public static const CONNECT:int = 0;
		//public static const SEND:int = 1;
		//public static const CLOSE:int = 2;
		
		public static const CONNECTED:int = 10;
		public static const CLOSED:int = 11;
		public static const DATA:int = 12;
		public static const DISPOSE:int = 13;
		
		public var command:int =-1;
		public var stream:ByteArray;
		public var payload:ByteArray;
		public var timestamp:int =-1;
		
		private var _host:String;
		private var _port:uint;
		
		public function WorkerSignal(cmd:int) 
		{
			command = cmd;
			stream = new ByteArray();
			stream.writeByte(command);
		}
		public function get host():String{
			return _host;
		}
		public function get port():uint{
			return _port;
		}
		public static function parse(command:ByteArray):WorkerSignal{
			command.position = 0;
			var signal:WorkerSignal = new WorkerSignal(command.readByte());
			signal.decompose(command);
			return signal;
		}
		private function decompose(byte:ByteArray):void{
			var len:uint;
			stream = byte;
			switch(command){
				case CONNECT:
					_host = readString();
					_port = readInteger();
					break;
				case DATA:
					timestamp = stream.readUnsignedInt();
					len = stream.readUnsignedShort();
					payload = new ByteArray();
					stream.readBytes(payload, 0, len);
					payload.position = 0;
					break;
				case CONNECTED:
				case CLOSED:
				case DISPOSE:
					break;
			}
		}
		public function writeString(str:String):void{
			var by:ByteArray = new ByteArray();
			by.writeUTFBytes(str);
			stream.writeByte(by.length);
			stream.writeUTFBytes(str);
		}
		public function writeInteger(num:uint):void{
			stream.writeUnsignedInt(num);
		}
		public function readString():String{
			var length:int = stream.readUnsignedByte();
			return stream.readUTFBytes(length);
		}
		public function readInteger():uint{
			return stream.readUnsignedInt();
		}
		public function compose():ByteArray{
			var ostream:ByteArray = stream;
			stream = new ByteArray();
			stream.writeByte(command);
			ostream.position = 0;
			return ostream;
		}
	}

}