package backend.util;

import objects.background.BackgroundPlanet;
import objects.background.BackgroundStar;
import flixel.util.FlxSpriteUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;

/**
 * Utility class for creating, generating and 
 * manipulating the world of Starcore.
 */
final class WorldUtil {
    
    private function new() {}

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

    public static function generateStars():FlxTypedGroup<BackgroundStar> {
        var stars = new FlxTypedGroup<BackgroundStar>();
		for (_ in 0...150) {
			stars.add(new BackgroundStar());
		}
        return stars;
    }
}
