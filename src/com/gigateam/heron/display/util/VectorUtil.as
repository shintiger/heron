package com.gigateam.heron.display.util 
{
	import com.gigateam.world.physics.shape.Vertex;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Tiger
	 */
	public class VectorUtil 
	{
		
		public function VectorUtil() 
		{
			
		}
		public static function toVertex(vec:Vector3D, out:Vertex = null):Vertex{
			if (out == null){
				out = new Vertex();
			}
			out.x = vec.x;
			out.y = vec.y;
			out.z = vec.z;
			return out;
		}
	}

}