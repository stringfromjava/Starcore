package starcore.graphics.states;

import flixel.group.FlxSpriteGroup;

/**
 * Special sprite group for display a menu UI over an `OpenableMenuState`.
 */
abstract class MenuDisplay extends FlxSpriteGroup
{
  /**
   * The `OpenableMenuState` that `this` menu is currently opened in.
   */
  public var parentState:OpenableMenuState;

  public function new(parentState:OpenableMenuState)
  {
    super();
    this.parentState = parentState;
  }

  /**
   * Gets called when it is first created an opened.
   */
  public abstract function create():Void;

  /**
   * Gets called when the menu is closed.
   */
  public abstract function close():Void;
}
