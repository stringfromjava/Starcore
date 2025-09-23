package starcore.graphics.states;

import flixel.FlxState;

/**
 * Special state that allows you to switch `MenuSubState`s with ease. 
 */
abstract class OpenableMenuState extends FlxState
{
  /**
   * The current menu being displayed.
   */
  var currentMenu:MenuDisplay = null;

  /**
   * Switches the current menu to a different one.
   * 
   * @param newMenu The new `MenuDisplay` to open.
   */
  public function switchMenu(newMenu:MenuDisplay):Void
  {
    if (currentMenu != null)
    {
      currentMenu.close();
      remove(currentMenu);
    }
    currentMenu = newMenu;
    currentMenu.create();
    add(currentMenu);
  }
}
