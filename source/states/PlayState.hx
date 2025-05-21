package states;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.FlxSprite;
import backend.data.Constants;
import flixel.util.FlxColor;
import backend.util.WorldUtil;
import objects.background.BackgroundPlanet;
import objects.background.BackgroundStar;
import flixel.group.FlxGroup.FlxTypedGroup;
import backend.util.PathUtil;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.tile.FlxTilemap;
import backend.Controls;
import flixel.FlxG;
import flixel.FlxCamera;
import flixel.FlxState;

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
    var mapCamera:FlxCamera;  // For the player, monstrosities, other entities, etc.

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
        mapCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        mapCamera.bgColor = FlxColor.BLACK;
        mapCamera.bgColor.alpha = 150;
        FlxG.cameras.add(mapCamera);

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
        worldTilemap.cameras = [mapCamera];
        add(worldTilemap);
        generateNewPlanet();

        // NOTE: NOT WORKING!!!!
        var test:FlxSprite = new FlxSprite();
        test.loadGraphic('assets/entities/default-player/default-player.png', true);
        test.scale.set(3, 3);
        test.updateHitbox();
        test.frames = FlxAtlasFrames.fromAseprite('assets/entities/default-player/default-player.png', 'assets/entities/default-player/default-player.json');
        test.animation.addByPrefix('head', 'head', 0, false);
        test.animation.play('head');
        test.setPosition(FlxG.width / 2, FlxG.height / 2);
        add(test);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);
        
        if (Controls.binds.M_UP_PRESSED) {
            worldTilemap.y += 13;
        }
        if (Controls.binds.M_LEFT_PRESSED) {
            worldTilemap.x += 13;
        }
        if (Controls.binds.M_DOWN_PRESSED) {
            worldTilemap.y -= 13;
        }
        if (Controls.binds.M_RIGHT_PRESSED) {
            worldTilemap.x -= 13;
        }

        if (Controls.binds.UI_SELECT_JUST_PRESSED) {
            generateNewPlanet();
        }
    }

    function generateNewPlanet(tileType:String = 'grass') {
        var caveData:String = WorldUtil.generateNewPlanetData([80, 200], [120, 300], 7, 0.528);
        worldTilemap.loadMapFromCSV(caveData, PathUtil.ofTileTexture(tileType), Constants.TILE_WIDTH, Constants.TILE_HEIGHT, AUTO);
        worldTilemap.updateBuffers();
    }
}
