package starcore.backend.data;

import haxe.Json;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import haxe.Exception;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;

/**
 * The shader options the user can change.
 * Each mode will display a different set of shaders, based on
 * what mode is set by the user.
 */
enum ShaderModeType
{
  #if ADVANCED_SHADERS_ALLOWED
  /**
   * All shaders applied (excluding Scanline).
   */
  DEFAULT;
  #end

  /**
   * Grain, Scanline, Hq2x and Tiltshift shaders are applied.
   */
  FAST;

  /**
   * Grain and Hq2x shaders are applied.
   */
  MINIMAL;

  /**
   * No shaders at all.
   */
  NONE;
}

/**
 * An anonymous structure that holds every option the user can
 * use in-game. This include things like graphics level, display settings,
 * volumes for specific things, and more.
 * 
 * NOTE: This does NOT include the user's controls! Those are held in
 * their own separate variable.
 */
typedef Options = {
  /**
   * The shader mode to use that changed the way the game looks.
   */
  var shaderMode:ShaderModeType;

  /**
   * Should the game display in the user's Discord "Activity" box?
   */
  var discordRPC:Bool;

  /**
   * Should the game lower its volume when it is out of focus?
   */
  var minimizeVolume:Bool;
}

/**
 * Class that handles, modifies and stores the user's
 * options and settings.
 * 
 * When you are updating a setting, use `setOption()` to update a user's option(s)
 * or `setBind()` to change a bind.
 * 
 * Controls are saved in their own variable, *NOT* in `options`.
 * 
 * The way controls are created is with this structure: `'keybind_id' => FlxKey.YOUR_KEY`.
 * To create a control, go to `starcore.backend.data.Constants`, search for `DEFAULT_CONTROLS_KEYBOARD`
 * and then add your controls accordingly.
 * 
 * To access controls, use `starcore.backend.Controls`. (**TIP**: Read `starcore.backend.Controls`'s
 * documentation for how to access if binds are pressed!)
 */
final class ClientPrefs
{
  /**
   * The default options if any other option doesn't exist.
   */
  static final DEFAULT_OPTIONS:Options = {
    shaderMode: #if !web DEFAULT #else FAST #end,
    discordRPC: true,
    minimizeVolume: true
  };

  static final DEFAULT_CONTROLS_KEYBOARD:Map<String, FlxKey> = [
    // Movement
    'mv_up' => W,
    'mv_left' => A,
    'mv_down' => S,
    'mv_right' => D,
    // UI
    'ui_left' => LEFT,
    'ui_down' => DOWN,
    'ui_up' => UP,
    'ui_right' => RIGHT,
    'ui_select' => ENTER,
    'ui_back' => ESCAPE,
    // Volume
    'vl_up' => PLUS,
    'vl_down' => MINUS,
    'vl_mute' => F12,
    // Misc.
    'ms_fullscreen' => F11,
    // Debug
    'db_openeditors' => F7
  ];

  static var controlsKeyboard:Map<String, FlxKey>;

  /**
   * The current options the user has set.
   */
  public static var options:Options = DEFAULT_OPTIONS;

  function new() {}

  //
  // GETTERS AND SETTERS
  // =====================================

  /**
   * Get and return a client bind by its ID.
   * 
   * @param bind The bind to get as a `String`.
   * @return     The value of the said bind. If it does not exist, then an
   *          exception is thrown.
   */
  public static inline function getBind(bind:String):FlxKey
  {
    if (controlsKeyboard.exists(bind))
    {
      return controlsKeyboard.get(bind);
    }
    else
    {
      LoggerUtil.log('Attempted to obtain non-existent bind "$bind".', ERROR, false);
      StarcoreG.closeGame(false);
      throw new Exception('Attempted to obtain non-existent bind "$bind".');
    }
  }

  /**
   * Get and return all client controls and binds.
   * 
   * @return A `Map` of all client binds.
   */
  public static inline function getBinds():Map<String, FlxKey>
  {
    return controlsKeyboard.copy();
  }

  /**
   * Get and return all default client options.
   * 
   * @return A copy of all default client options.
   */
  public static inline function getDefaultBinds():Map<String, FlxKey>
  {
    return DEFAULT_CONTROLS_KEYBOARD.copy();
  }

  /**
   * Get and return all default client options.
   * 
   * @return A copy of all default client options.
   */
  public static inline function getDefaultOptions():Options
  {
    return Json.parse(Json.stringify(DEFAULT_OPTIONS));
  }

  /**
   * Set a specific key bind for the user.
   * 
   * @param bind        The bind to be set.
   * @param newKey      The key to set it to.
   * @throws Exception  If the bind does not exist.
   */
  public static function setBind(bind:String, newKey:FlxKey):Void
  {
    if (controlsKeyboard.exists(bind))
    {
      controlsKeyboard.set(bind, newKey);
    }
    else
    {
      LoggerUtil.log('Attempted to change non-existent bind "$bind".', ERROR, false);
      StarcoreG.closeGame(false);
      throw new Exception('Attempted to change non-existent bind "$bind".');
    }
  }

  //
  // METHODS
  // =============================

  /**
   * Load and obtain all of the user's options and controls.
   */
  public static function loadAll():Void
  {
    // Log info
    LoggerUtil.log('Loading all client preferences');

    // Create the binds
    var optionsData:FlxSave = new FlxSave();
    var controlsData:FlxSave = new FlxSave();

    // Connect to the saves
    optionsData.bind(Constants.OPTIONS_SAVE_BIND_ID, PathUtil.getSavePath());
    controlsData.bind(Constants.CONTROLS_SAVE_BIND_ID, PathUtil.getSavePath());

    // Load options
    if (optionsData.data.options != null)
    {
      options = optionsData.data.options;
    }

    // Check if the user has any new options
    // (this is for when new options are added in an update!)
    for (field in Reflect.fields(DEFAULT_OPTIONS))
    {
      if (!Reflect.hasField(options, field))
      {
        Reflect.setField(options, field, Reflect.field(DEFAULT_OPTIONS, field));
      }
    }

    // Set the shaders based on the user's options
    StarcoreG.setFilters(options.shaderMode);

    // Load all player controls and binds.
    if (controlsData.data.keyboard != null)
    {
      controlsKeyboard = controlsData.data.keyboard;
    }
    else
    {
      controlsKeyboard = DEFAULT_CONTROLS_KEYBOARD;
    }

    // Check if the user has any new controls
    // (this is for when new controls are added in an update!)
    for (key in DEFAULT_CONTROLS_KEYBOARD.keys())
    {
      if (!controlsKeyboard.exists(key))
      {
        controlsKeyboard.set(key, DEFAULT_CONTROLS_KEYBOARD.get(key));
      }
    }

    // Filter out any binds that are not present in the current
    // standard set of binds (which is determined by the default binds)
    for (key in controlsKeyboard.keys())
    {
      if (!DEFAULT_CONTROLS_KEYBOARD.exists(key))
      {
        controlsKeyboard.remove(key);
      }
    }

    // Respectfully close the saves to prevent data leaks
    optionsData.close();
    controlsData.close();
  }
}
