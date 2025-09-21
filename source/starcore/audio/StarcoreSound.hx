package starcore.audio;

import starcore.backend.util.AudioUtil;
import flixel.sound.FlxSound;

/**
 * An enhanced version of `FlxSound` with additional features.
 */
class StarcoreSound extends FlxSound
{
  @:access(openfl.media.SoundMixer)
  override function play(forceRestart:Bool = false, startTime:Float = 0.0, ?endTime:Float):FlxSound
  {
    var sound:FlxSound = super.play(forceRestart, startTime, endTime);
    @:privateAccess AudioUtil.regenSound(_sound);
    return sound;
  }
}
