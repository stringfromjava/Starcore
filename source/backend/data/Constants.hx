package backend.data;

import flixel.input.keyboard.FlxKey;

/**
 * Class that holds all of the general values that do not change.
 */
final class Constants {
    
    /**
	 * The default controls for the player. This is typically used when
     * the player wishes to reset all of their binds.
     */
	public static final DEFAULT_CONTROLS_KEYBOARD:Map<String, FlxKey> = [
        // Movement
        'm_up'       => FlxKey.W,
        'm_left'     => FlxKey.A,
        'm_down'     => FlxKey.S,
        'm_right'    => FlxKey.D,

        // UI
        'ui_left'    => FlxKey.LEFT,
        'ui_down'    => FlxKey.DOWN,
        'ui_up'      => FlxKey.UP,
        'ui_right'   => FlxKey.RIGHT,
        'ui_select'  => FlxKey.ENTER,
        'ui_back'    => FlxKey.ESCAPE,

        // Volume
        'v_up'       => FlxKey.PLUS,
        'v_down'     => FlxKey.MINUS,
        'v_mute'     => FlxKey.F12,
    ];
    
    /**
     * The name of the save file for the player's options.
     */
    public static final OPTIONS_SAVE_BIND_ID:String = 'options';

    /**
     * The name of the save file for the player's controls.
     */
    public static final CONTROLS_SAVE_BIND_ID:String = 'controls';

    /**
     * The name of the save file for the player's progress.
     */
    public static final PROGRESS_SAVE_BIND_ID:String = 'progress';

    /**
     * How long it takes for the fade effect to last when switching states.
     */
    public static final TRANSITION_DURATION:Float = 0.4;

    /**
	 * Name of the music that plays when in the main menus.
     */
    public static final MENU_MUSIC_NAME:String = 'Stargazer';

	/**
	 * The maximum amount of reverb sound effects that can be played at once.
	 */
	public static final REVERB_SOUND_EFFECT_LIMIT:Int = 15;

	/**
	 * How fast background stars scroll in the distance.
	 */
	public static final BACKGROUND_STAR_SCROLL_SPEED:Float = 0.7;

	/**
	 * How fast background planets scroll in the distance.
	 */
	public static final BACKGROUND_PLANET_SCROLL_SPEED:Float = 0.3;

	/**
	 * How long it takes in seconds until the stars change their alpha value.
	 */
	public static final STAR_CHANGE_ALPHA_DELAY:Float = 2;

	/**
	 * A regular expression that holds characters which are valid for
	 * creating names for entities and items.
	 */
	public static final VALID_ITEM_ENTITY_NAME_CHARACTERS:EReg = ~/[a-z_]/;

    /**
     * How wide in pixels a tile is. This is used for the world tilemap.
     */
    public static final TILE_WIDTH:Int = 16;

    /**
     * How height in pixels a tile is. This is used for the world tilemap.
     */
    public static final TILE_HEIGHT:Int = 16;

    private function new() {}
}
