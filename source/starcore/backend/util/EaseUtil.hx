package starcore.backend.util;

/**
 * Utility class for easing functions on tweens.
 */
final class EaseUtil
{
  function new() {}

  /**
   * Returns an ease function that eases via steps.
   * Useful for "retro" style fades.
   * 
   * @param steps How many steps to ease over.
   * @return Float->Float
   */
  public static inline function stepped(steps:Int):Float->Float
  {
    return function(t:Float):Float
    {
      return Math.floor(t * steps) / steps;
    }
  }
}
