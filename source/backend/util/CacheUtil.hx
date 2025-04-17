package backend.util;

/**
 * Class that holds general, temporary data for pretty much anything.
 * Examples of general temporary data can be things such as the last volume used.
 */
final class CacheUtil {
    
    /**
     * The last volume that the player had set before the game loses focus.
     */
    public static var lastVolumeUsed:Float;

    /**
     * Did the user already see the intro?
     * (This is for loading from and to the main menu when the game hasn't closed yet.)
     */
    public static var alreadySawIntro:Bool = false;

	/**
	 * Is the game's window focused?
	 */
	public static var isWindowFocused:Bool = true;

    /**
     * Can the game play menu music when the user leaves gameplay?
     */
    public static var canPlayMenuMusic:Bool = true;

    /**
     * The amount of echo sounds that are currently playing.
     */
    public static var currentEchoSoundsAmount:Int = 0;

    private function new() {}
}
