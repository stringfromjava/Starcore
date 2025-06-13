package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.Assets;
import starcore.backend.util.PathUtil;

// https://www.shadertoy.com/view/Ms23DR
// https://www.shadertoy.com/view/MsXGD4

/**
 * Allows the screen to bend like an old school TV.
 */
class VCRBorderShader extends FlxRuntimeShader
{
	public function new()
	{
		super(Assets.getText(PathUtil.ofFrag('vcrborder')));
	}
}
