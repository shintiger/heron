package com.gigateam.heron.display.layer3d 
{
	import alternativa.engine3d.animation.AnimationClip;
	import alternativa.engine3d.loaders.Parser;
	import alternativa.engine3d.loaders.ParserCollada;
	import alternativa.engine3d.objects.Skin;
	import com.gigateam.heron.display.util.Util3D;
	/**
	 * ...
	 * @author Tiger
	 */
	public class SkinLibraryItem extends MeshLibraryItem
	{
		private var _srcClip:AnimationClip;
		private var _skin:Skin;
		private var _animator:Animator;
		public function SkinLibraryItem(parser:Parser, skin:String) 
		{
			super(parser, skin);
			_skin = _mesh as Skin;
			_srcClip = _parser.getAnimationByObject(_skin);
			_animator = new Animator(_srcClip);
		}
		public function getAnimator():Animator{
			var cloned:Skin = getMesh() as Skin;
			var an:Animator = new Animator(Util3D.cloneAnimationClip(_srcClip, cloned));
			return an;
		}
	}

}