package starcore.backend.data;

import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import haxe.Exception;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;
import starcore.backend.util.SaveUtil;

/**
 * The shader options the user can change.
 * Each mode will display a different set of shaders, based on
 * what mode is set by the user.
 */
enum ShaderModeType
{
  /**
   * All shaders applied (excluding Scanline)
   */
  DEFAULT;

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

// abstract Options

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
  static var options:Map<String, Any> = Constants.DEFAULT_OPTIONS;
  static var controlsKeyboard:Map<String, FlxKey>;

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
   * Get and return a client option by its ID.
   * 
   * @param option       The option to get as a `String`.
   * @return             The value of the option. If it does not exist, then an
   *              exception is thrown.
   */
  public static inline function getOption(option:String):Dynamic
  {
    if (options.exists(option))
    {
      return options.get(option);
    }
    else
    {
      LoggerUtil.log('Client option "$option" doesn\'t exist!', ERROR, false);
      StarcoreG.closeGame(false);
      throw new Exception('Client option "$option" doesn\'t exist!');
    }
  }

  /**
   * Get and return all client options.
   * 
   * @return A `Map` of all client options.
   */
  public static inline function getOptions():Map<String, Any>
  {
    return options.copy();
  }

  /**
   * Sets a client's option.
   * 
   * @param option      The setting to be set.
   * @param value       The value to set the option to.
   * @throws Exception  If the option does not exist.
   */
  public static function setOption(option:String, value:Any):Void
  {
    if (options.exists(option))
    {
      options.set(option, value);
      SaveUtil.saveUserOptions();
    }
    else
    {
      LoggerUtil.log('Client option "$option" doesn\'t exist!', ERROR, false);
      StarcoreG.closeGame(false);
      throw new Exception('Client option "$option" doesn\'t exist!');
    }
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
      options = optionsData.data.options;

    // Check if the user has any new options
    // (this is for when new options are added in an update!)
    for (key in Constants.DEFAULT_OPTIONS.keys())
    {
      if (!options.exists(key))
      {
        options.set(key, Constants.DEFAULT_OPTIONS.get(key));
      }
    }

    // Filter out any options that are not present in the current
    // standard set of options (which is determined by the default options)
    for (key in options.keys())
    {
      if (!Constants.DEFAULT_OPTIONS.exists(key))
      {
        options.remove(key);
      }
    }

    // Set the shaders based on the user's options
    // TODO: FIX THIS ASAP!!!
    StarcoreG.setFilters(getOption('shaderMode'));

    // Load controls
    if (controlsData.data.keyboard != null)
      controlsKeyboard = controlsData.data.keyboard;
    else
      controlsKeyboard = Constants.DEFAULT_CONTROLS_KEYBOARD;

    // Check if the user has any new controls
    // (this is for when new controls are added in an update!)
    for (key in Constants.DEFAULT_CONTROLS_KEYBOARD.keys())
    {
      if (!controlsKeyboard.exists(key))
      {
        controlsKeyboard.set(key, Constants.DEFAULT_CONTROLS_KEYBOARD.get(key));
      }
    }

    // Filter out any binds that are not present in the current
    // standard set of binds (which is determined by the default binds)
    for (key in controlsKeyboard.keys())
    {
      if (!Constants.DEFAULT_CONTROLS_KEYBOARD.exists(key))
      {
        controlsKeyboard.remove(key);
      }
    }

    // Set the volume to the last used volume the user had
    if (optionsData.data.lastVolume != null)
      FlxG.sound.volume = optionsData.data.lastVolume;
    else
      FlxG.sound.volume = 1.0;

    // Respectfully close the saves to prevent data leaks
    optionsData.close();
    controlsData.close();
  }
}
