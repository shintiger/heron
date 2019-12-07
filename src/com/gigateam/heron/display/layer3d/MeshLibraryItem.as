package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.loaders.Parser;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.materials.Material;
	import alternativa.engine3d.objects.Mesh;
	/**
	 * ...
	 * @author Tiger
	 */
	public class MeshLibraryItem 
	{
		protected var _defaultMat:Material;
		protected var _mesh:Mesh;
		protected var _parser:ParserCollada;
		public function MeshLibraryItem(parser:Parser, mesh:String) 
		{
			_parser = parser as ParserCollada;
			_mesh = parser.getObjectByName(mesh) as Mesh;
		}
		public function getMesh():Mesh{
			var cloned:Mesh = _mesh.clone() as Mesh;
			if (_defaultMat != null){
				cloned.setMaterialToAllSurfaces(_defaultMat);
			}
			
			return cloned;
		}
		public function setDefaultMaterial(mat:Material):void{
			_defaultMat = mat;
		}
	}

}