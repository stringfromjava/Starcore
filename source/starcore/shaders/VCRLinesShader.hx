package starcore.shaders;

import flixel.FlxG;
import openfl.Assets;
import starcore.backend.util.PathUtil;
import starcore.shaders.bases.UpdatedShader;

/**
 * Adds a bending scanline effect to the screen, simulating old VCR playback.
 */
class VCRLinesShader extends UpdatedShader
{
  public function new()
  {
    super(Assets.getText(PathUtil.ofFrag('vcrlines')));
  }

  public function update(elapsed:Float):Void
  {
    setFloat('time', FlxG.game.ticks * FlxG.elapsed);
  }
}
