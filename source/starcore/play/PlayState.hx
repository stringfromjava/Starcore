package starcore.play;

import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import starcore.backend.Controls;
import starcore.backend.data.Constants;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;
import starcore.backend.util.WorldUtil;
import starcore.background.BackgroundPlanet;
import starcore.background.BackgroundStar;
import starcore.menus.MainMenuState;

/**
 * Core state where all of the major and common gameplay
 * occurs for the player(s), entities, etc.
 */
class PlayState extends FlxState
{
  /**
   * The static instance used to access attributes of the
   * PlayState from anywhere, in any state.
   * 
   * Note that it will stay `null` until it is switched to for the first time.
   */
  public static var instance:PlayState = null;

  //
  // CAMERAS
  // ======================================
  /**
   * The camera that displays the background elements, such as stars and planets.
   */
  public var backgroundCamera:FlxCamera;

  /**
   * The camera that displays the world elements, such as tilemaps and entities.
   * This also includes the players.
   */
  public var worldCamera:FlxCamera;

  //
  // BACKGROUND ELEMENTS
  // ==============================================
  var planets:FlxTypedGroup<BackgroundPlanet>;
  var stars:FlxTypedGroup<BackgroundStar>;

  //
  // TILEMAP COMPONENTS
  // ========================================
  var worldTilemap:FlxTilemap;

  //
  // METHOD OVERRIDES
  // ==================================

  override function create():Void
  {
    super.create();

    // Set the instance of the PlayState.
    if (instance != null)
    {
      LoggerUtil.log('Static PlayState attribute is not null. This should not happen!', WARNING, false);
    }

    instance = this;

    setupCameras();
    setupBackground();
    setupWorld();
  }

  override function update(elapsed:Float):Void
  {
    super.update(elapsed);

    if (Controls.getBinds().MV_UP_PRESSED)
    {
      worldTilemap.y += 13;
    }
    if (Controls.getBinds().MV_LEFT_PRESSED)
    {
      worldTilemap.x += 13;
    }
    if (Controls.getBinds().MV_DOWN_PRESSED)
    {
      worldTilemap.y -= 13;
    }
    if (Controls.getBinds().MV_RIGHT_PRESSED)
    {
      worldTilemap.x -= 13;
    }

    if (Controls.getBinds().UI_BACK_JUST_PRESSED)
    {
      FlxG.switchState(() -> new MainMenuState());
    }

    if (Controls.getBinds().UI_SELECT_JUST_PRESSED)
    {
      generateNewPlanet();
    }

    scrollCamerasFromMousePos(elapsed);
  }

  //
  // SETUP FUNCTIONS
  // ====================================

  function setupCameras():Void
  {
    // Set the background camera.
    backgroundCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    backgroundCamera.bgColor = FlxColor.BLACK;
    FlxG.cameras.add(backgroundCamera);

    // Set the map camera.
    worldCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
    worldCamera.bgColor = FlxColor.BLACK;
    worldCamera.bgColor.alpha = 150;
    FlxG.cameras.add(worldCamera, false);
  }

  function setupBackground():Void
  {
    // Add the stars and planets in the background.
    planets = WorldUtil.generatePlanets();
    stars = WorldUtil.generateStars();
    planets.cameras = [backgroundCamera];
    stars.cameras = [backgroundCamera];
    add(planets);
    add(stars);
  }

  function setupWorld():Void
  {
    // Set the tilemap.
    worldTilemap = new FlxTilemap();
    worldTilemap.scale.set(4, 4);
    worldTilemap.updateBuffers();
    worldTilemap.cameras = [worldCamera];
    add(worldTilemap);
    generateNewPlanet();

    var test:FlxSprite = new FlxSprite();
    var paths:Array<String> = PathUtil.ofEntityTexture('player');
    test.loadGraphic(paths[0], true);
    test.scale.set(3, 3);
    test.updateHitbox();
    test.frames = FlxAtlasFrames.fromSparrow(paths[0], paths[1]);
    test.animation.addByIndices('torso', 'torso_', [0], '', 0, false);
    test.animation.play('torso');
    test.setPosition(FlxG.width / 2, FlxG.height / 2);
    test.cameras = [worldCamera];
    add(test);
  }

  //
  // PLANET FUNCTIONS
  // ===================================

  function generateNewPlanet(tileType:String = 'grass'):Void
  {
    var caveData:String = WorldUtil.generateNewPlanetData([80, 200], [120, 300], 7, 0.528);
    worldTilemap.loadMapFromCSV(caveData, PathUtil.ofTileTexture(tileType), Constants.TILE_WIDTH, Constants.TILE_HEIGHT, AUTO);
    worldTilemap.updateBuffers();
  }

  //
  // EFFECT FUNCTIONS
  // ======================================

  function scrollCamerasFromMousePos(elapsed:Float):Void
  {
    // Scroll background camera.
    backgroundCamera.scroll.x = FlxMath.lerp(backgroundCamera.scroll.x,
      (FlxG.mouse.viewX - (FlxG.width / 2)) * Constants.BACKGROUND_CAMERA_SCROLL_MULTIPLIER, (1 / 30) * 240 * elapsed);
    backgroundCamera.scroll.y = FlxMath.lerp(backgroundCamera.scroll.y,
      (FlxG.mouse.viewY - 6 - (FlxG.height / 2)) * Constants.BACKGROUND_CAMERA_SCROLL_MULTIPLIER, (1 / 30) * 240 * elapsed);
    // Scroll world camera.
    worldCamera.scroll.x = FlxMath.lerp(worldCamera.scroll.x, (FlxG.mouse.viewX - (FlxG.width / 2)) * Constants.WORLD_CAMERA_SCROLL_MULTIPLIER,
      (1 / 30) * 240 * elapsed);
    worldCamera.scroll.y = FlxMath.lerp(worldCamera.scroll.y, (FlxG.mouse.viewY - 6 - (FlxG.height / 2)) * Constants.WORLD_CAMERA_SCROLL_MULTIPLIER,
      (1 / 30) * 240 * elapsed);
  }
}
