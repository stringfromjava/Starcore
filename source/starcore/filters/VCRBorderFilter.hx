package starcore.filters;

import starcore.backend.util.PathUtil;
import openfl.Assets;
import flixel.addons.display.FlxRuntimeShader;

// https://www.shadertoy.com/view/Ms23DR and https://www.shadertoy.com/view/MsXGD4

/**
 * Allows the screen to bend like an old school TV.
 */
class VCRBorderFilter extends FlxRuntimeShader
{
	public function new()
	{
		super(Assets.getText(PathUtil.ofFrag('vcrborder')));
	}
}
