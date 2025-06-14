package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;
import starcore.backend.util.PathUtil;

/**
 * Adds a slight blur to the entire screen.
 */
class Hq2xShader extends FlxRuntimeShader
{
	public function new()
	{
		super(Assets.getText(PathUtil.ofFrag('hq2x')));
	}
}
