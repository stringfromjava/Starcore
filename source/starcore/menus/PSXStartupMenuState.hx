package starcore.menus;

import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.util.FlxTimer;
import starcore.audio.StarcoreSound;
import starcore.backend.util.EaseUtil;
import starcore.backend.util.PathUtil;
import starcore.menus.main.MainMenuState;

/**
 * The startup menu state that mimics the classic PlayStation startup sequence.
 */
class PSXStartupMenuState extends FlxState
{
  var sonyLogo:FlxSprite;
  var psxLogo:FlxSprite;

  override function create():Void
  {
    super.create();

    var diskSound:StarcoreSound = StarcoreG.playSound(PathUtil.ofSharedSound('startup/console-disk-loading'), 0.25);
    new FlxTimer().start((diskSound.length / 1000) / 1.65, (_) ->
    {
      diskSound.stop();

      // Load the PSX logo first so it can be shown after the Sony logo.
      var paths:Array<String> = PathUtil.ofSharedSpritesheet('startup/psx-startup-playstation');
      psxLogo = new FlxSprite();
      psxLogo.loadGraphic(PathUtil.ofSharedImage(paths[0]), true);
      psxLogo.frames = FlxAtlasFrames.fromSparrow(paths[0], paths[1]);
      psxLogo.animation.addByPrefix('psx-startup-playstation', 'psx-startup-playstation_', 18, false);
      psxLogo.useFramePixels = true;
      psxLogo.visible = false;
      psxLogo.setGraphicSize(FlxG.width, FlxG.height);
      psxLogo.updateHitbox();
      psxLogo.screenCenter(X);
      psxLogo.y = 0;
      add(psxLogo);

      var paths:Array<String> = PathUtil.ofSharedSpritesheet('startup/psx-startup-sony');
      sonyLogo = new FlxSprite();
      sonyLogo.loadGraphic(PathUtil.ofSharedImage(paths[0]), true);
      sonyLogo.frames = FlxAtlasFrames.fromSparrow(paths[0], paths[1]);
      sonyLogo.animation.addByPrefix('psx-startup-sony', 'psx-startup-sony_', 18, false);
      sonyLogo.useFramePixels = true;
      sonyLogo.animation.play('psx-startup-sony');
      sonyLogo.setGraphicSize(FlxG.width, FlxG.height);
      sonyLogo.updateHitbox();
      sonyLogo.screenCenter(X);
      sonyLogo.y = 0;
      sonyLogo.animation.onFinish.add((animName:String) ->
      {
        // Small delay after Sony logo before showing PSX logo.
        new FlxTimer().start(2.5, (_) ->
        {
          sonyLogo.visible = false;
          psxLogo.visible = true;
          psxLogo.animation.play('psx-startup-playstation');
          // Another delay before tweening the alpha and switching to main menu.
          new FlxTimer().start(6.2, (_) ->
          {
            FlxTween.tween(psxLogo, {alpha: 0}, 1.2, {ease: EaseUtil.stepped(8)});
          });
        });
      });
      add(sonyLogo);

      var startupSound:StarcoreSound = StarcoreG.playSound(PathUtil.ofSharedSound('startup/psx'));
      startupSound.onComplete = () ->
      {
        FlxG.switchState(() -> new MainMenuState());
      };
    });
  }
}
