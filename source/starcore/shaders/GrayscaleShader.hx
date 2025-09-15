package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.utils.Assets;
import starcore.backend.util.PathUtil;

/**
 * What do you think?
 */
class GrayscaleShader extends FlxRuntimeShader
{
  public function new(amount:Float = 1)
  {
    super(Assets.getText(PathUtil.ofFrag('grayscale')));
    setFloat("_amount", amount);
  }

  public function setAmount(value:Float):Void
  {
    setFloat("_amount", value);
  }
}
