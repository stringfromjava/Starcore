package starcore.menus.main;

import flixel.group.FlxSpriteGroup;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import starcore.backend.Controls;
import starcore.backend.util.PathUtil;
import starcore.graphics.states.MenuDisplay;
import starcore.ui.UIClickableSprite;

/**
 * The menu for displaying the title of the game.
 */
class TitleMenuDisplay extends MenuDisplay
{
  var logo:FlxText;

  var buttons:Array<String> = ['play', 'quit'];
  var buttonsGroup:FlxSpriteGroup;
  var buttonClickFunctions:Map<String, Void->Void>;
  var buttonWasClicked:Bool = false;

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (Controls.getBinds().UI_BACK_JUST_PRESSED)
    {
      StarcoreG.closeGame();
    }
  }

  function create():Void
  {
    // Setup the logo that says "STARCORE".
    // TODO: Replace with a better logo.
    logo = new FlxText();
    logo.text = 'STARCORE';
    logo.size = 165;
    logo.color = FlxColor.WHITE;
    logo.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(50, 50, 50), 8);
    logo.updateHitbox();
    logo.setPosition((FlxG.width / 2) - (logo.width / 2), 0);
    add(logo);

    // Setup the main menu buttons.
    buttonsGroup = new FlxSpriteGroup();
    add(buttonsGroup);

    buttonClickFunctions = [
      'play' => () ->
      {
        parentState.switchMenu(new SavesMenuDisplay(parentState));
      },
      'quit' => () ->
      {
        StarcoreG.closeGame();
      }
    ];

    var newY:Float = 350; // Change this to the starting Y position for the menu buttons
    for (btn in buttons)
    {
      var coolSwaggerButton:UIClickableSprite = new UIClickableSprite();
      coolSwaggerButton.loadGraphic(PathUtil.ofSharedImage('menus/main/$btn-button'));
      coolSwaggerButton.scale.set(4, 4);
      coolSwaggerButton.updateHitbox();
      coolSwaggerButton.behavior.updateHoverBounds(coolSwaggerButton.x, coolSwaggerButton.y, coolSwaggerButton.width, coolSwaggerButton.height);
      coolSwaggerButton.setPosition(0, newY);
      coolSwaggerButton.behavior.onClick = buttonClickFunctions.get(btn);
      coolSwaggerButton.behavior.onHover = () ->
      {
        StarcoreG.playSoundWithReverb(PathUtil.ofSharedSound('blip'), 1);
        FlxSpriteUtil.setBrightness(coolSwaggerButton, 0.3);
      };
      coolSwaggerButton.behavior.onHoverLost = () ->
      {
        if (!buttonWasClicked)
        {
          FlxSpriteUtil.setBrightness(coolSwaggerButton, 0);
        }
      };
      buttonsGroup.add(coolSwaggerButton);
      newY += coolSwaggerButton.height + 40;
    }
  }

  function close():Void {}
}
