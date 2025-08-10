package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.Assets;
import starcore.backend.util.PathUtil;

// https://www.shadertoy.com/view/ldjGzV
// https://www.shadertoy.com/view/Ms23DR
// https://www.shadertoy.com/view/MsXGD4
// https://www.shadertoy.com/view/Xtccz4

/**
 * Gives the screen a creepy, old Super Mario-like vibe.
 */
class VCRMario85Shader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(PathUtil.ofFrag('vcrmario85')));
    setFloat('time', 0);
  }

  public function update(elapsed:Float):Void
  {
    setFloat('time', getFloat('time') + elapsed);
  }
}
