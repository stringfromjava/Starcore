package states;

import backend.Controls;
import flixel.FlxG;
import flixel.FlxCamera;
import objects.world.WorldTilemap;
import flixel.FlxState;

/**
 * Core state where all of the major and common gameplay
 * occurs for the player(s), entities, etc.
 */
class PlayState extends FlxState {

    // World components for shit like
    // tiles, the tilemap, etc.
    var worldTilemap:WorldTilemap;
    
    // Cameras
    var mapCamera:FlxCamera;

    override function create() {
        super.create();

        // Set the cameras
        mapCamera = new FlxCamera(0, 0, FlxG.width, FlxG.height);
        mapCamera.bgColor.alpha = 0;
        FlxG.cameras.add(mapCamera);

        // Load the tilemap
        worldTilemap = new WorldTilemap(25, 30, 3);
        worldTilemap.cameras = [mapCamera];
        add(worldTilemap);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.binds.M_LEFT_PRESSED) {
            mapCamera.scroll.x -= 4;
        } else if (Controls.binds.M_RIGHT_PRESSED) {
            mapCamera.scroll.x += 4;
        }
    }
}
