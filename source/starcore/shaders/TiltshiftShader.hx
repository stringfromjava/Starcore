package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;
import starcore.backend.util.PathUtil;

/**
 * Adds a slight blur to the top and bottom edges of the screen.
 */
class TiltshiftShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(PathUtil.ofFrag('tiltshift')));
  }
}
