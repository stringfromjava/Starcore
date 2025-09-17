package starcore.shaders;

import openfl.Assets;
import openfl.Lib;
import starcore.backend.util.PathUtil;

/**
 * Adds a grainy effect to the screen like an old TV
 * (hence the name).
 */
class GrainShader extends UpdatedShader
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
