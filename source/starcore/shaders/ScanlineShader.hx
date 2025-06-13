package starcore.shaders;

import starcore.backend.util.PathUtil;
import openfl.Assets;
import flixel.addons.display.FlxRuntimeShader;

/**
 * Adds old TV lines across the screen.
 */
class ScanlineShader extends FlxRuntimeShader
{
	public function new()
	{
		super(Assets.getText(PathUtil.ofFrag('scanline')));
	}
}
