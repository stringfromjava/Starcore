package starcore.menus.main;

import starcore.graphics.states.MenuDisplay;

/**
 * Menu display for showing a list of all save files the user has.
 */
class SavesMenuDisplay extends MenuDisplay
{
  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (FlxG.keys.justPressed.BACKSPACE)
    {
      parentState.switchMenu(new TitleMenuDisplay(parentState));
    }
  }

  function create():Void
  {
    add(new FlxText('bruh moment', 64));
  }

  function close():Void {}
}
