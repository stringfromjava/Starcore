package starcore;

import starcore.audio.StarcoreSound;

/**
 * An enhanced version of `FlxG` with additional features.
 */
class StarcoreG
{
  /**
   * Plays a `StarcoreSound` from the specified path with the given parameters.
   * 
   * @param path   The path to the sound file.
   * @param volume The volume level of the sound (0.0 to 1.0).
   * @param loop   Whether the sound should loop.
   * @param pitch  The pitch of the sound.
   * @return The sound instance that was played.
   */
  public static function playSound(path:String, volume:Float = 1.0, loop:Bool = false, pitch:Float = 1.0):StarcoreSound
  {
    var sound:StarcoreSound = new StarcoreSound();
    sound.loadEmbedded(path);
    sound.volume = volume;
    sound.looped = loop;
    sound.pitch = pitch;
    sound.play();
    return sound;
  }
}
