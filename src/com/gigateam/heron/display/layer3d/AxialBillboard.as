package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.alternativa3d;
	import alternativa.engine3d.core.Camera3D;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.primitives.Plane;
	import flash.display3D.Context3DTextureFormat;
	import flash.display3D.Context3DTriangleFace;
	import flash.geom.Vector3D;
	/**
	 * ...
	 * @author Tiger
	 */
	
	use namespace alternativa3d;
	public class AxialBillboard extends Plane
	{
		protected var _d:Vector3D = new Vector3D(0, 0, 0);
		public function AxialBillboard(width:Number=100, length:Number=100, widthSegments:uint=1, lengthSegments:uint=1, bottom:Material=null, top:Material=null) 
		{
			super(width, length, widthSegments, lengthSegments, true, false, bottom, top);
		}
		public function get direction():Vector3D{
			return _d;
		}
		public function updateRotation(x:Number, y:Number, z:Number):void{
			_d.x = x;
			_d.y = y;
			_d.z = z;
			_d.normalize();
			_updateRotation();
		}
		override alternativa3d function calculateVisibility(camera:Camera3D):void {
			super.calculateVisibility(camera);
			face(camera);
		}
		private function face(camera:Object3D):void{
			var camV:Vector3D = new Vector3D();
			var camPos:Vector3D = camera.localToGlobal(new Vector3D());
			camV.x = camPos.x - x;
			camV.y = camPos.y - y;
			camV.z = camPos.z - z;
			camV.normalize();
			
			var right:Vector3D = camV.crossProduct(direction);
			camV = camV.crossProduct(right);
			right.normalize();
			camV.normalize();
			rotationX = 0;
			var ry:Number = rotationY;
			var rz:Number = rotationZ;
			//rotationY = 0;
			//rotationZ = 0;
			camV.x += x;
			camV.y += y;
			camV.z += z;
			camV = globalToLocal(camV);
			
			var r:Number = -Math.atan2(camV.y, camV.z);
			rotationX = r;
		}
		private function _updateRotation():void{
			rotationY = Math.atan2(_d.z, Math.sqrt(_d.x * _d.x + _d.y * _d.y));
			rotationZ = - Math.atan2(_d.x, _d.y)-0.5*Math.PI;
		}
	}

}