package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;
import openfl.Assets;
import starcore.backend.util.PathUtil;

class SkewShader extends FlxRuntimeShader
{
  public function new()
  {
    super(Assets.getText(PathUtil.ofFrag('skew')));
  }
}
