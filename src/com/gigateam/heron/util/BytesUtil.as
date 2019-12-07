package com.gigateam.heron.util 
{
	import flash.utils.ByteArray;
	/**
	 * ...
	 * @author Tiger
	 */
	public class BytesUtil 
	{
		
		public function BytesUtil() 
		{
			
		}
		public static function writeInt24(bytes:ByteArray, num:int):void{
			bytes.writeByte((num >> 16) & 0xff);
			bytes.writeByte((num >> 8) & 0xff);
			bytes.writeByte(num & 0xff);
		}
		public static function readInt24(bytes:ByteArray):int{
			return (bytes.readUnsignedByte() << 16) | (bytes.readUnsignedByte() << 8) | (bytes.readUnsignedByte() & 0xff);
		}
	}

}