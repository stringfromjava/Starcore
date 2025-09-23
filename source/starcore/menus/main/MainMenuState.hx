package starcore.menus.main;

import flixel.group.FlxGroup.FlxTypedGroup;
import starcore.backend.util.WorldUtil;
import starcore.background.BackgroundPlanet;
import starcore.background.BackgroundStar;
import starcore.graphics.states.OpenableMenuState;

/**
 * State that represents the main menu of the game.
 * This is where the player can start a new game, load a game, or quit the game.
 */
class MainMenuState extends OpenableMenuState
{
  var stars:FlxTypedGroup<BackgroundStar>;
  var planets:FlxTypedGroup<BackgroundPlanet>;

  override function create():Void
  {
    super.create();

    StarcoreG.playMenuMusic();

    // Add the background elements.
    planets = WorldUtil.generatePlanets();
    add(planets);

    stars = WorldUtil.generateStars();
    add(stars);

    switchMenu(new TitleMenuDisplay(this));
  }
}
