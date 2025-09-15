package starcore.filters;

import flixel.addons.display.FlxRuntimeShader;
import openfl.Assets;
import starcore.backend.util.PathUtil;

/**
 * Allows a sprite to shift its colors
 * to another set.
 */
class HueShiftShader extends FlxRuntimeShader
{
  public function new(hue:Float = 0)
  {
    super(Assets.getText(PathUtil.ofFrag('hueshift')));
    setHue(hue);
  }

  public function setHue(amount:Float):Void
  {
    setFloat('hue', amount);
  }
}
