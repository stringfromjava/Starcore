package starcore.shaders;

import flixel.addons.display.FlxRuntimeShader;

/**
 * Base class for shaders that need to be updated every frame.
 */
abstract class UpdatedShader extends FlxRuntimeShader
{
  public function new(?fragCode:String)
  {
    super(fragCode);
  }

  /**
   * Function which is called every frame to update the shader.
   * 
   * @param elapsed The amount of time (in seconds) since the last frame.
   */
  public abstract function update(elapsed:Float):Void;
}
