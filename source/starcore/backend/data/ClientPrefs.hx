package starcore.backend.data;

import starcore.backend.util.PathUtil;
import starcore.backend.util.SaveUtil;
import flixel.FlxG;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxSave;
import haxe.Exception;

/**
 * Class that handles, modifies and stores the user's
 * options and settings.
 * 
 * When you are updating a setting, use `setOption()` to update a user's option(s)
 * or `setBind()` to change a bind.
 * 
 * Controls are saved in their own variable, *NOT* in `_options`.
 * 
 * The way controls are created is with this structure: `'keybind_id' => FlxKey.YOUR_KEY`.
 * To create a control, go to `backend.data.Constants`, search for `DEFAULT_CONTROLS_KEYBOARD`
 * and then add your controls accordingly.
 * 
 * To access controls, use `backend.Controls`. (**TIP**: Read `backend.Controls`'s
 * documentation for accessing if binds are pressed!)
 */
final class ClientPrefs {

	private static var _options:Map<String, Any> = Constants.DEFAULT_OPTIONS;
	private static var _controlsKeyboard:Map<String, FlxKey>;

	private function new() {}

	// ==============================
	//      GETTERS AND SETTERS
	// ==============================

	/**
	 * Get and return a client bind by its ID.
	 * 
	 * @param bind The bind to get as a `String`.
	 * @return     The value of the said bind. If it does not exist, then the
	 *             default value is returned instead.
	 */
	public static inline function getBind(bind:String):FlxKey {
		if (_controlsKeyboard.exists(bind)) {
			return _controlsKeyboard.get(bind);
		} else {
			FlxG.log.error('Attempted to obtain non-existent bind "$bind".');
			throw new Exception('No such bind as "$bind".');
		}
	}

	/**
	 * Get and return all client controls and binds.
	 * 
	 * @return A `Map` of all client binds.
	 */
	public static inline function getBinds():Map<String, FlxKey> {
		return _controlsKeyboard.copy();
	}

	/**
	 * Get and return a client option by its ID.
	 * 
	 * @param option       The option to get as a `String`.
	 * @param defaultValue The value that is returned instead if the said option isn't found.
	 * @return             The value of the option. If it does not exist, then the
	 *                     default value is returned instead.
	 */
	public static inline function getOption(option:String):Dynamic {
		if (_options.exists(option)) {
			return _options.get(option);
		} else {
			FlxG.log.error('Client option "$option" doesn\'t exist!');
			throw new Exception('Client option "$option" doesn\'t exist!');
		}
	}

	/**
	 * Get and return all client options.
	 * 
	 * @return A `Map` of all client options.
	 */
	public static inline function getOptions():Map<String, Any> {
		return _options.copy();
	}

	/**
	 * Sets a client's option.
	 * 
	 * @param option      The setting to be set.
	 * @param value       The value to set the option to.
	 * @throws Exception  If the option does not exist.
	 */
	public static function setOption(option:String, value:Any):Void {
		if (_options.exists(option)) {
			_options.set(option, value);
			SaveUtil.saveUserOptions();
		} else {
			FlxG.log.error('Client option "$option" doesn\'t exist!');
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
	public static function setBind(bind:String, newKey:FlxKey):Void {
		if (_controlsKeyboard.exists(bind)) {
			_controlsKeyboard.set(bind, newKey);
		} else {
			FlxG.log.error('Attempted to change non-existent bind "$bind".');
			throw new Exception('No such bind as "$bind".');
		}
	}

	// =============================
	//            METHODS
	// =============================

	/**
	 * Load and obtain all of the user's options and controls.
	 */
	public static function loadAll():Void {
		// Create the binds
		var optionsData:FlxSave = new FlxSave();
		var controlsData:FlxSave = new FlxSave();

		// Connect to the saves
		optionsData.bind(Constants.OPTIONS_SAVE_BIND_ID, PathUtil.getSavePath());
		controlsData.bind(Constants.CONTROLS_SAVE_BIND_ID, PathUtil.getSavePath());

		// Load options
		if (optionsData.data.options != null)
			_options = optionsData.data.options;

		// Check if the user has any new options
		// (this is for when new options are added in an update!)
		for (key in Constants.DEFAULT_OPTIONS.keys()) {
			if (!_options.exists(key)) {
				_options.set(key, Constants.DEFAULT_OPTIONS.get(key));
			}
		}

		// Filter out any options that are not present in the current
		// standard set of options (which is determined by the default options)
		for (key in _options.keys()) {
			if (!Constants.DEFAULT_OPTIONS.exists(key)) {
				_options.remove(key);
			}
		}

		// Load controls
		if (controlsData.data.keyboard != null)
			_controlsKeyboard = controlsData.data.keyboard;
		else
			_controlsKeyboard = Constants.DEFAULT_CONTROLS_KEYBOARD;

		// Check if the user has any new controls
		// (this is for when new controls are added in an update!)
		for (key in Constants.DEFAULT_CONTROLS_KEYBOARD.keys()) {
			if (!_controlsKeyboard.exists(key)) {
				_controlsKeyboard.set(key, Constants.DEFAULT_CONTROLS_KEYBOARD.get(key));
			}
		}

		// Filter out any binds that are not present in the current
		// standard set of binds (which is determined by the default binds)
		for (key in _controlsKeyboard.keys()) {
			if (!Constants.DEFAULT_CONTROLS_KEYBOARD.exists(key)) {
				_controlsKeyboard.remove(key);
			}
		}

		// Set the volume to the last used volume the user had
		if (optionsData.data.lastVolume != null)
			FlxG.sound.volume = optionsData.data.lastVolume;
		else
			FlxG.sound.volume = 1.0;

		// Log all recorded info
		FlxG.log.add('Loaded all client options and controls successfully!');

		// Respectfully close the saves to prevent data leaks
		optionsData.close();
		controlsData.close();
	}
}
