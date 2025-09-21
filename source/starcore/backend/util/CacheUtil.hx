package starcore.backend.util;

import starcore.entity.Entity;

/**
 * Class that holds general, temporary data for pretty much anything.
 * Examples of general temporary data can be things such as the last volume used.
 */
final class CacheUtil
{
  /**
   * Can the game play menu music when the user leaves gameplay?
   */
  public static var canPlayMenuMusic:Bool = true;

  /**
   * The amount of reverb sounds that are currently playing.
   */
  public static var currentReverbSoundsAmount:Int = 0;

  /**
   * Registered entities that are currently in the game.
   */
  public static var registeredEntities:Array<Entity> = [];

  function new() {}
}
