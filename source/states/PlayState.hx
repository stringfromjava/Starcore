package states;

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

        var test:FlxSprite = new FlxSprite();
        test.loadGraphic(PathUtil.ofEntitySpritesheetTexture('default-player'), true);
        test.scale.set(3, 3);
        test.updateHitbox();
		test.frames = FlxAtlasFrames.fromSparrow(PathUtil.ofEntitySpritesheetTexture('default-player'), PathUtil.ofEntitySpritesheetData('default-player'));
		test.animation.addByIndices('left_arm', 'left_arm_', [0], '', 0, false);
		test.animation.play('left_arm');
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
		worldTilemap.loadMapFromCSV(caveData, PathUtil.ofTileSpritesheetTexture(tileType), Constants.TILE_WIDTH, Constants.TILE_HEIGHT, AUTO);
        worldTilemap.updateBuffers();
    }
}
