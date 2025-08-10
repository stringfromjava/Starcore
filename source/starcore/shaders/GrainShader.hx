package starcore.shaders;

import openfl.Lib;
import flixel.addons.display.FlxRuntimeShader;
import openfl.Assets;
import starcore.backend.util.PathUtil;

/**
 * Adds a grainy effect to the screen like an old TV
 * (hence the name).
 */
class GrainShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(PathUtil.ofFrag('grain')));
  }

  public function update(elapsed:Float):Void
  {
    setFloat('uTime', (Lib.getTimer() / 1000) * elapsed);
  }
}
