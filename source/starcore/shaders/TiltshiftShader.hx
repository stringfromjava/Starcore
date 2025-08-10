package starcore.shaders;

import starcore.backend.util.PathUtil;
import openfl.utils.Assets;
import flixel.addons.display.FlxRuntimeShader;

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
