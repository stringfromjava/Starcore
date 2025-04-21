package objects.world;

import backend.data.Constants;
import backend.util.PathUtil;
import filters.HueShiftFilter.HueShiftShader;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.util.FlxColor;

/**
 * Enum for how a tile is oriented in the world.
 */
enum abstract TileOrientation(String) from String to String {
    public inline static var UP = 'up';
    public inline static var MIDDLE = 'middle';
    public inline static var RIGHT = 'right';
}

enum abstract TilePosition(String) from String to String {
    public inline static var LEFT = 'left';
    public inline static var MIDDLE = 'middle';
    public inline static var RIGHT = 'right';
}

/**
 * Component for creating the world of Starcore.
 */
class WorldTilemap extends FlxTypedGroup<FlxSprite> {
    
    /**
     * How wide in tiles `this` world tilemap is.
     */
    public var wWidth(get, never):Int;
    private var _wWidth:Int;

    /**
     * How tall in tiles `this` world tilemap is.
     */
    public var wHeight(get, never):Int;
    private var _wHeight:Int;

    public function new(wWidth:Int, wHeight:Int, zoom:Float = 1) {
        super(wWidth * wHeight);
        this._wWidth = wWidth;
        this._wHeight = wHeight;

        var nx:Float = 0;
        var ny:Float = 0;
        for (w in 0...wWidth) {
            for (h in 0...wHeight) {
                var tile:FlxSprite = new FlxSprite();
                var filter:HueShiftShader = new HueShiftShader();
                tile.loadGraphic(PathUtil.ofTileTexture('grass', 'top', 'left'));
                tile.setGraphicSize(Constants.TILE_WIDTH * zoom, Constants.TILE_HEIGHT * zoom);
                tile.updateHitbox();
                tile.setPosition(nx, ny);
                filter.setHue(FlxG.random.float(0.0, 1.0));
                tile.shader = filter;
                add(tile);
                ny += Constants.TILE_HEIGHT * zoom;
            }
            nx += Constants.TILE_WIDTH * zoom;
            ny = 0;
        }
    }

    // ------------------------------
    //      GETTERS AND SETTERS
    // ------------------------------

    @:noCompletion
    public inline function get_wWidth():Int {
        return this._wWidth;
    }

    @:noCompletion
    public inline function get_wHeight():Int {
        return this._wHeight;
    }
}
