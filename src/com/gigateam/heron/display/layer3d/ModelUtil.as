package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.animation.AnimationSwitcher;
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.core.Resource;
	import alternativa.engine3d.loaders.Parser;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.loaders.TexturesLoader;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Joint;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import alternativa.engine3d.resources.Geometry;
	import flash.display3D.Context3D;
	import flash.display3D.textures.TextureBase;
	import flash.utils.ByteArray;
	import starling.textures.Texture;
	/**
	 * ...
	 * @author Tiger
	 */
	public class ModelUtil extends Object3D
	{
		protected var _rootObj:Object3D;
		protected var _baseURL:String;
		public function ModelUtil() 
		{
		}
		public static function toSingleObject(parser:Parser, out:Object3D = null):Object3D{
			var object:Object3D;
			if (out == null){
				out = new Object3D();
			}
			for each (object in parser.hierarchy) {
				trace(object);
				out.addChild(object);
			}
			return out;
		}
		public static function toTextureMaterial(parser:Parser, preuploadTexture:Texture=null):void{
			switchMaterial(parser, 0, preuploadTexture);
		}
		public static function toStandardMaterial(parser:Parser, preuploadTexture:Texture=null):void{
			switchMaterial(parser, 1, preuploadTexture);
		}
		public static function setMaterialToAllSurfaces(object3D:Object3D, material:Material):void{
			if (object3D is Mesh){
				(object3D as Mesh).setMaterialToAllSurfaces(material);
				return;
			}
			var i:int;
			var obj:Object3D;
			for (i = 0; i < object3D.numChildren; i++){
				setMaterialToAllSurfaces(object3D.getChildAt(i), material);
			}
		}
		public static function eachSurface(mesh:Mesh, callback:Function):void{
			var i:int;
			for (i = 0; i < mesh.numSurfaces; i++){
				var surface:Surface = mesh.getSurface(i);
				var mat:ParserMaterial = surface.material as ParserMaterial;
				if (mat == null){
					continue;
				}
				surface.material = callback(mat.textures);
			}
		}
		private static function switchMaterial(parser:Parser, materialType:int, preuploadTexture:Texture=null):void{
			var object:Object3D;
			var mesh:Mesh;
			var standardMaterial:Material;
			for each (object in parser.objects) {
				if(object is Mesh){
					mesh = object as Mesh;
					if(mesh==null){
						mesh.parent.removeChild(mesh);
						continue;
					}
				}else{
					switch(object.name){
						default:
							break;
					}
					continue;
				}
				
				var surface:Surface;
				for (var i:int = 0; i < mesh.numSurfaces; i++) {
					surface = mesh.getSurface(i);
					var material:ParserMaterial = surface.material as ParserMaterial;
					traceTextures(material);
					if (material != null) {
						var j:int;
						var diffuse:ExternalTextureResource = material.textures["diffuse"];
						if (diffuse != null) {
							if (preuploadTexture != null){
								diffuse.data = preuploadTexture.base;
							}
							//textures.push(diffuse);
							if (standardMaterial == null){
								switch(materialType){
									case 0:
										standardMaterial = new TextureMaterial(diffuse);
										break;
									case 1:
										standardMaterial = new StandardMaterial(diffuse, diffuse, diffuse, diffuse);
										break;
								}
							}
							surface.material = standardMaterial;
						}else{
							trace("[Warning]: Diffuse not exists");
						}
					}
				}
			}
		}
		private static function traceTextures(material:ParserMaterial):void{
			if (material == null){
				return;
			}
			var i:int = 0;
			for (var key:String in material.textures){
				trace("[" + key + "]", material.textures[key]);
			}
		}
		public static function traceObjectNames(parser:Parser, recursive:Boolean=true):void{
			var i:int = 0;
			trace(parser, "count:", parser.objects.length);
			for (i = 0; i < parser.objects.length; i++){
				trace(parser.objects[i], parser.objects[i].name);
			}
		}
		public static function fromParser(parser:Parser, container:Object3D):void{
			var standardMaterial:TextureMaterial;
			var mesh:Mesh;
			var object:Object3D;
			for each (object in parser.hierarchy) {
				container.addChild(object);
			}
			for each (object in parser.objects) {
				if(object is Mesh){
					mesh = object as Mesh;
					if(mesh==null){
						mesh.parent.removeChild(mesh);
						object = container.getChildByName(mesh.name);
						object.parent.removeChild(object);
						continue;
					}
				}else{
					//Special handling for specific name
					switch(object.name){
						default:
							break;
					}
					continue;
				}
				
				var surface:Surface;
				for (var i:int = 0; i < mesh.numSurfaces; i++) {
					surface = mesh.getSurface(i);
					var material:ParserMaterial = surface.material as ParserMaterial;
					if (material != null) {
						var j:int;
						var diffuse:ExternalTextureResource = material.textures["diffuse"];
						if (diffuse != null) {
							//textures.push(diffuse);
							if (standardMaterial == null){
								standardMaterial = new TextureMaterial(diffuse);
							}
							surface.material = standardMaterial;
						}
					}
				}
			}
		}
		public static function from3DS(data:ByteArray, baseURL:String=""):Object3D{
			var parser:Parser3DS = new Parser3DS();
			parser.parse(data, baseURL);
			var container:Object3D = new Object3D();
			fromParser(parser, container);
			return container;
		}
		public static function fromCollada(data:XML, baseURL:String = ""):Object3D{
			var parser:ParserCollada = new ParserCollada();
			parser.parse(data, baseURL, true);
			var container:Object3D = new Object3D();
			fromParser(parser, container);
			return container;
		}
		public static function getMaterialByName(name:String, textures:Vector.<StandardMaterial>):StandardMaterial{
			return null;
		}
		public static function getChildByName(childName:String, container:Object3D):Object3D{
			if (container.name == childName){
				return container;
			}
			var ch:Object3D = container.getChildByName(childName);
			if(ch!=null){
				return ch;
			}
			for (var i:int = 0; i < container.numChildren; i++){
				ch = getChildByName(childName, container.getChildAt(i));
				if(ch!=null){
					return ch;
				}
			}
			return null;
		}
		public static function getChildren(container:Object3D, recursively:Boolean = true, vec:Vector.<Object3D> = null):Vector.<Object3D>{
			if (vec == null){
				vec = new Vector.<Object3D>();
			}
			var obj:Object3D;
			for (var i:int = 0; i < container.numChildren; i++){
				obj = container.getChildAt(i);
				vec.push(obj);
				if (recursively && obj.numChildren > 1){
					getChildren(obj, recursively, vec);
				}
			}
			return vec;
		}
	}

}