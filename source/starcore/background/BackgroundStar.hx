package starcore.background;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxTimer;
import starcore.backend.data.Constants;
import starcore.backend.util.PathUtil;

/**
 * Represents a background star in the game.
 */
class BackgroundStar extends FlxSprite
{
  // Add a timer that changes the alpha of the stars every few seconds
  var starChangeAlphaTimer:FlxTimer = new FlxTimer();

  public function new()
  {
    super();
    loadGraphic(PathUtil.ofSharedImage('bg/star'));
    scale.set(3, 3);
    updateHitbox();
    setPosition(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height));
    alpha = FlxG.random.float(0.3, 1);

    // Add a timer that changes the alpha of the stars every few seconds
    starChangeAlphaTimer.start(Constants.STAR_CHANGE_ALPHA_DELAY, (_) ->
    {
      alpha = FlxG.random.float(0.3, 1);
    }, 0);
  }

  override public function update(elapsed:Float):Void
  {
    super.update(elapsed);
    x += Constants.BACKGROUND_STAR_SCROLL_SPEED;
    if (x > FlxG.width)
    {
      x = 0 - width;
    }
  }
}
