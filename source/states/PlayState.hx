package states;

import states.menus.MainMenuState;
import flixel.math.FlxMath;
import backend.Controls;
import backend.data.Constants;
import backend.util.PathUtil;
import backend.util.WorldUtil;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxTilemap;
import flixel.util.FlxColor;
import objects.background.BackgroundPlanet;
import objects.background.BackgroundStar;

/**
 * Core state where all of the major and common gameplay
 * occurs for the player(s), entities, etc.
 */
class PlayState extends FlxState {

    // Background stars and planets
    var planets:FlxTypedGroup<BackgroundPlanet>;
    var stars:FlxTypedGroup<BackgroundStar>;

    // Tilemap shit
    var worldTilemap:FlxTilemap;
    
    // Cameras
    var backgroundCamera:FlxCamera;  // For the stars and planets in the background
    var worldCamera:FlxCamera;  // For the player, monstrosities, other entities, etc.

    override function create() {
        super.create();

        // -------------
        //    CAMERAS
        // -------------

        // Set the background camera
        backgroundCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        backgroundCamera.bgColor = FlxColor.BLACK;
        FlxG.cameras.add(backgroundCamera);

        // Set the map camera
        worldCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        worldCamera.bgColor = FlxColor.BLACK;
        worldCamera.bgColor.alpha = 150;
        FlxG.cameras.add(worldCamera, false);

        // ----------------
        //    BACKGROUND
        // ----------------

        // Add the stars and planets in the background
        planets = WorldUtil.generatePlanets();
        stars = WorldUtil.generateStars();
        planets.cameras = [backgroundCamera];
        stars.cameras = [backgroundCamera];
        add(planets);
        add(stars);

        // -----------
        //    WORLD
        // -----------

        // Set the tilemap
        worldTilemap = new FlxTilemap();
        worldTilemap.scale.set(4, 4);
        worldTilemap.updateBuffers();
        worldTilemap.cameras = [worldCamera];
        add(worldTilemap);
        generateNewPlanet();

        var test:FlxSprite = new FlxSprite();
        var paths:Array<String> = PathUtil.ofEntitySpritesheet('default-player');
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

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (Controls.getBinds().MV_UP_PRESSED) {
            worldTilemap.y += 13;
        }
        if (Controls.getBinds().MV_LEFT_PRESSED) {
            worldTilemap.x += 13;
        }
        if (Controls.getBinds().MV_DOWN_PRESSED) {
            worldTilemap.y -= 13;
        }
        if (Controls.getBinds().MV_RIGHT_PRESSED) {
            worldTilemap.x -= 13;
        }

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.switchState(() -> new MainMenuState());
        }

        if (Controls.getBinds().UI_SELECT_JUST_PRESSED) {
            generateNewPlanet();
        }

        scrollCamerasFromMousePos(elapsed);
    }

    function generateNewPlanet(tileType:String = 'grass') {
        var caveData:String = WorldUtil.generateNewPlanetData([80, 200], [120, 300], 7, 0.528);
		worldTilemap.loadMapFromCSV(caveData, PathUtil.ofTileSpritesheetTexture(tileType), Constants.TILE_WIDTH, Constants.TILE_HEIGHT, AUTO);
        worldTilemap.updateBuffers();
    }

    function scrollCamerasFromMousePos(elapsed:Float):Void {
        // Scroll background camera
        backgroundCamera.scroll.x = FlxMath.lerp(backgroundCamera.scroll.x, (FlxG.mouse.viewX - (FlxG.width / 2)) * Constants.BACKGROUND_CAMERA_SCROLL_MULTIPLIER, (1 / 30) * 240 * elapsed);
		backgroundCamera.scroll.y = FlxMath.lerp(backgroundCamera.scroll.y, (FlxG.mouse.viewY - 6 - (FlxG.height / 2)) * Constants.BACKGROUND_CAMERA_SCROLL_MULTIPLIER, (1 / 30) * 240 * elapsed);
        // Scroll world camera
        worldCamera.scroll.x = FlxMath.lerp(worldCamera.scroll.x, (FlxG.mouse.viewX - (FlxG.width / 2)) * Constants.WORLD_CAMERA_SCROLL_MULTIPLIER, (1 / 30) * 240 * elapsed);
		worldCamera.scroll.y = FlxMath.lerp(worldCamera.scroll.y, (FlxG.mouse.viewY - 6 - (FlxG.height / 2)) * Constants.WORLD_CAMERA_SCROLL_MULTIPLIER, (1 / 30) * 240 * elapsed);
    }
}
