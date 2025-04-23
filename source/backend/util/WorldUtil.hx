package backend.util;

import backend.data.Constants;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.tile.FlxCaveGenerator;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.util.FlxSpriteUtil;
import objects.background.BackgroundPlanet;
import objects.background.BackgroundStar;

/**
 * Utility class for creating, generating and 
 * manipulating the world of Starcore.
 */
final class WorldUtil {
    
    private function new() {}

	/**
	 * Generates a new string of cave data for a new planet.
	 * Note that this only returns data, you will still need to do your
	 * own logic and call `updateBuffers()` on your tilemap!
	 * 
	 * @param widthRange  Array of ***2*** integers. The range of how *wide* the world can be. 
	 * @param heightRange Array of ***2*** integers. The range of how *tall* the world can be. 
	 * @param SI          Short for "Smoothing Iterations". This is how many times the cave will be smoothed.
	 *                    The higher the number, the smoother the cave will be.
	 * @param WR          Short for "Wall Ratio". This is how many walls there are in the planet. The higher the number, the more walls there will be.
	 * @return 			  A fresh new string of CSV data for a new planet.
	 */
	public static function generateNewPlanetData(widthRange:Array<Int>, heightRange:Array<Int>, SI:Int, WR:Float):String {
		var width:Int = FlxG.random.int(80, 200);
		var height:Int = FlxG.random.int(120, 400);
		var caveData:String = FlxCaveGenerator.generateCaveString(width, height, SI, WR);
		return caveData;
	}

	/**
	 * Generates an `FlxTypedGroup` of background planets.
	 * 
	 * @return A group of background planets.
	 */
    public static function generatePlanets():FlxTypedGroup<BackgroundPlanet> {
		var planets = new FlxTypedGroup<BackgroundPlanet>();
		for (_ in 0...8) {
            planets.add(new BackgroundPlanet());
        }
		planets.members.sort((a:BackgroundPlanet, b:BackgroundPlanet) -> {
			var areaA = a.width * a.height;
			var areaB = b.width * b.height;
			if (areaA > areaB) return -1;
			if (areaA < areaB) return 1;
			return 0;
		});
        return planets;
    }

	/**
	 * Generates an `FlxTypedGroup` of background stars.
	 * 
	 * @return A group of background stars.
	 */
    public static function generateStars():FlxTypedGroup<BackgroundStar> {
        var stars = new FlxTypedGroup<BackgroundStar>();
		for (_ in 0...150) {
			stars.add(new BackgroundStar());
		}
        return stars;
    }
}
