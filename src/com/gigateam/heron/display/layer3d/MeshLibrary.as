package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.objects.Mesh;
	import alternativa.engine3d.objects.Skin;
	import com.gigateam.heron.AssetLoader;
	/**
	 * ...
	 * @author Tiger
	 */
	public class MeshLibrary 
	{
		private var _loader:AssetLoader;
		private var _dict:Object;
		public function MeshLibrary(loader:AssetLoader) 
		{
			_loader = loader;
			_dict = {};
		}
		public function add(id:String, item:MeshLibraryItem):void{
			_dict[id] = item;
		}
		public function createMesh(id:String):Mesh{
			var item:MeshLibraryItem = getTemplate(id);
			if (item == null){
				return null;
			}
			return item.getMesh();
		}
		public function createAnimator(id:String):Animator{
			var item:SkinLibraryItem = getTemplate(id) as SkinLibraryItem;
			if (item == null){
				return null;
			}
			return item.getAnimator();
		}
		public function getTemplate(id:String):MeshLibraryItem{
			if (!_dict.hasOwnProperty(id)){
				return null;
			}
			return _dict[id] as MeshLibraryItem;
		}
		
	}

}