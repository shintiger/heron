package com.gigateam.heron 
{
	import alternativa.engine3d.core.Object3D;
	import alternativa.engine3d.loaders.Parser;
	import alternativa.engine3d.loaders.Parser3DS;
	import alternativa.engine3d.loaders.ParserA3D;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.loaders.ParserFBX;
	import alternativa.engine3d.loaders.ParserMaterial;
	import alternativa.engine3d.materials.StandardMaterial;
	import alternativa.engine3d.materials.TextureMaterial;
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Surface;
	import alternativa.engine3d.resources.BitmapTextureResource;
	import alternativa.engine3d.resources.ExternalTextureResource;
	import com.gigateam.heron.display.layer3d.ModelUtil;
	import flash.display.Bitmap;
	import flash.display3D.textures.TextureBase;
	import flash.filesystem.File;
	import flash.media.Sound;
	import flash.utils.ByteArray;
	import starling.display.Image;
	import starling.display.MovieClip;
	import starling.textures.Texture;
	import starling.textures.TextureAtlas;
	import starling.utils.AssetManager;
	import starling.utils.SystemUtil;
	/**
	 * ...
	 * @author Tiger
	 */
	public class AssetLoader extends AssetManager
	{
		private var _numAsset:int = 0;
		private var _resourceDir:File;
		private var _textureDir:File;
		private var _resourceTree:ResourceTree;
		public function AssetLoader(resourceDir:File, textureDir:File=null) 
		{
			_resourceDir = resourceDir;
			_textureDir = textureDir;
			_resourceTree = new ResourceTree(_resourceDir.url);
			
			useMipMaps = true;
		}
		public function get root():File{
			return _resourceDir;
		}
		public function getSubTexture(altlasName:String, subTextureName:String = ""):Texture{
			if (subTextureName == ""){
				var splitted:Array = altlasName.split(".");
				if (splitted.length == 2){
					altlasName = splitted[0];
					subTextureName = splitted[1];
				}
			}
			return getTextureAtlas(altlasName).getTexture(subTextureName+"0000");
		}
		public function getSubTextures(altlasName:String, subTextureNamePrefix:String, out:Vector.<Texture>=null):Vector.<Texture>{
			return getTextureAtlas(altlasName).getTextures(subTextureNamePrefix, out);
		}
		public function getImage(name:String):Image{
			var splitted:Array = name.split(".");
			if (splitted.length == 2){
				return new Image(getSubTexture(splitted[0], splitted[1]));
			}
			return new Image(getTexture(splitted[0]));
		}
		public function getMovieClip(name:String):MovieClip{
			var splitted:Array = name.split(".");
			if (splitted.length == 2){
				return new MovieClip(getSubTextures(splitted[0], splitted[1]), 60);
			}
			return null;
		}
		private function idToPath(id:String):File{
			return _resourceDir.resolvePath(id.replace(".", "/"));
		}
		override public function enqueue(...args):void{
			super.enqueue.apply(this, args);
		}
		public function enqueueGroup(dirname:String):void{
			trace("enqueue", dirname);
			enqueue(_resourceDir.resolvePath(dirname));
		}
		override public function loadQueue(onProgress:Function):void{
			for (var i:int in queue){
				_numAsset++;
			}
			_resourceTree.add(queue);
			super.loadQueue(onProgress);
		}
		public function removeGroup(dirname:String):void{
			var names:Vector.<String> = _resourceTree.getNamesByDir(dirname);
			for (var i:int = 0; i < names.length; i++){
				var name:String = names[i];
				var _class:Class = getClassOfAsset(name);
				switch(_class){
					case Texture:
						removeTexture(name, true);
						break;
					case TextureAtlas:
						removeTextureAtlas(name, true);
						break;
					case XML:
						removeXml(name, true);
						break;
					case Sound:
						removeSound(name);
						break;
					default:
						continue;
						break;
				}
				_numAsset--;
			}
		}
		public function get numAsset():int{
			return _numAsset;
		}
		public function getClassOfAsset(name:String):Class{
			if (getTexture(name) != null){
				return Texture;
			}else if (getTextureAtlas(name) != null){
				return TextureAtlas;
			}else if (getXml(name) != null){
				return XML;
			}else if (getSound(name) != null){
				return Sound;
			}else if (getByteArray(name) != null){
				return ByteArray;
			}
			
			return null;
		}
		public function getExternalTextureResource(filename:String):ExternalTextureResource{
			var ext:ExternalTextureResource = new ExternalTextureResource(filename);
			ext.data = getTexture(filename).base;
			return ext;
		}
		public function getParserFBX(filename:String):ParserFBX{
			var data:ByteArray = getByteArray(filename);
			var parser:ParserFBX = new ParserFBX();
			parser.parse(data);
			return parser;
		}
		public function getParser(filename:String, autofillExternalResource:Boolean=true):Parser{
			if (_textureDir == null && autofillExternalResource){
				throw new Error("Provide texture directory at constructor if you need 3D texture");
			}
			var parser:Parser;
			var data:ByteArray;
			var dir:String = autofillExternalResource ? (_textureDir.url + "/") : "";
			data = getByteArray(filename);
			if (data == null){
				var dataXML:XML = getXml(filename);
				var parserCollada:ParserCollada = new ParserCollada();
				parserCollada.parse(dataXML, dir, true);
				parser = parserCollada;
			}else{
				try{
					var parserA3D:ParserA3D = new ParserA3D();
					parserA3D.parse(data);
					parser = parserA3D;
				}catch(e:Error){
					var parser3DS:Parser3DS = new Parser3DS();
					parser3DS.parse(data, dir);
					parser = parser3DS;
				}
			}
			if (autofillExternalResource){
				ModelUtil.toTextureMaterial(parser, getTexture(filename));
			}
			return parser;
		}
		override protected function loadRawAsset(rawAsset:Object, onProgress:Function, onComplete:Function):void{
			super.loadRawAsset(rawAsset, onProgress,
				function (asset:Object):void{
					if (asset is Bitmap){
						// here, you can access the bitmap
						var bitmap:Bitmap = asset as Bitmap;
						//trace("Bitmap:", bitmap.blendMode, bitmap.width, bitmap.height);
						//BitmapTextureResource.createMips(
					}
					onComplete(asset);
			});
		}
	}
}