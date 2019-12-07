package com.gigateam.heron.display.util 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.materials.FillMaterial;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.primitives.GeoSphere;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.TextureResource;
	import com.gigateam.heron.display.layer3d.ModelUtil;
	import flash.display.BitmapData;
	/**
	 * ...
	 * @author Tiger
	 */
	public class Util3D 
	{
		
		public function Util3D() 
		{
			
		}
		public static function coloredStandardMaterial(color:int = 0x7F7F7F, opacityMap:TextureResource=null):StandardMaterial {
			var material:StandardMaterial;
			material = new StandardMaterial(createColorTexture(color), createColorTexture(0x7F7FFF), null, null, opacityMap);
			material.alphaThreshold = 1;
			return material;
		}
		public static function createColorTexture(color:uint, alpha:Boolean = false):BitmapTextureResource {
			return new BitmapTextureResource(new BitmapData(1, 1, alpha, color));
		}
		public static function createPoint(radius:Number, color:int, target:Object3D = null):Mesh{
			var point:GeoSphere = new GeoSphere(radius, 2, false, new FillMaterial(color));
			if (target) target.addChild(point);
			return point;
		}
		public static function cloneAnimationClip(clip:AnimationClip, clonedTarget:Object3D):AnimationClip{
			var clonedClip:AnimationClip = clip.clone();
			var i:int;
			var objects:Array = [];
			var child:Object3D;
			for (i = 0; i<clip.objects.length; i++){
				var obj:Object3D = clip.objects[i] as Object3D;
				if (obj == null){
					continue;
				}
				var name:String = obj.name;
				child = ModelUtil.getChildByName(name, clonedTarget);
				if (child == null){
					return null;
				}
				objects.push(child);
			}
			clonedClip.objects = objects;
			return clonedClip;
		}
	}

}