package starcore.shaders;

import starcore.backend.util.PathUtil;
import openfl.Assets;
import flixel.addons.display.FlxRuntimeShader;

/**
 * Adds old TV lines across the screen.
 * 
 * This is only really used when the user's option
 * `'shaderMode'` isn't set to `starcore.backend.data.ClientPrefs.ShaderModeType.DEFAULT`
 * ***OR*** when the user is playing on a web build (i.e. HTML5).
 */
class ScanlineShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(PathUtil.ofFrag('scanline')));
  }
}
