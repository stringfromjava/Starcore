package;

import starcore.backend.Controls;
import openfl.events.KeyboardEvent;
import starcore.backend.data.Constants;
import openfl.display.StageQuality;
import starcore.objects.entity.ComplexEntity;
import flixel.util.FlxColor;
import starcore.backend.util.SaveUtil;
import flixel.tweens.FlxTween;
import flixel.math.FlxMath;
import starcore.backend.util.CacheUtil;
import starcore.backend.data.ClientPrefs;
import starcore.backend.util.PathUtil;
import flixel.system.FlxAssets;
import starcore.states.menus.MainMenuState;
import starcore.filters.*;
import openfl.filters.ShaderFilter;
import sys.thread.Thread;
import flixel.FlxG;
import flixel.FlxState;
#if DISCORD_ALLOWED
import starcore.backend.api.DiscordClient;
#end
import lime.app.Application;
import openfl.Lib;
import openfl.display.StageScaleMode;
#if html5
import js.Browser;
#end

/**
 * The initial state of the game. This is where
 * you can load assets and set up the game.
 */
class InitState extends FlxState {

	override public function create() {
		// Assign and configure flixel settings
		configureFlixelSettings();

		// Add the processes that always run in the background
		addBackgroundProcesses();

		// Add the event listeners
		addEventListeners();

		// Load all of the player's settings and options
		// Note that if this line is not present, it will
		// cause null errors and crash the game!
		ClientPrefs.loadAll();

		// Register all of the entities that are in the game
		registerEntities();

		// Start up Discord rich presence
		#if DISCORD_ALLOWED
		DiscordClient.initialize();
		#end

		// Switch to the main menu state after everything has loaded
		FlxG.switchState(() -> new MainMenuState());
	}

	function configureFlixelSettings():Void {
		// Set the cursor to be the system default
		FlxG.mouse.useSystemCursor = true;

		// Set auto pause to false
		FlxG.autoPause = false;

		// Set the stage and scaling modes
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		// Disable the binds for increasing/decreasing/muting
		// the flixel master volume
		FlxG.sound.volumeUpKeys = [];
		FlxG.sound.volumeDownKeys = [];
		FlxG.sound.muteKeys = [];

		// Set the default font
		FlxAssets.FONT_DEFAULT = PathUtil.ofFont('Born2bSportyFS');

		// Set the stage quality
		FlxG.stage.quality = StageQuality.MEDIUM;

		// Disable the right-click context menu for HTML5
		#if html5
		Browser.document.addEventListener("contextmenu", (e) -> {
			e.preventDefault();
		});
		#end

		// Apply cool but creepy filters
		#if FILTERS_ALLOWED
		FlxG.game.setFilters([
			new ShaderFilter(CacheUtil.angelFilter),
			new ShaderFilter(CacheUtil.vcrBorderFilter),
			new ShaderFilter(CacheUtil.vcrMario85Filter),
			new ShaderFilter(CacheUtil.ycbuEndingFilter)
		]);
		#end
	}

	function addBackgroundProcesses():Void {
		// Update the filters that need to
		// constantly be reset
		#if FILTERS_ALLOWED
		FlxG.signals.postUpdate.add(() -> {
			CacheUtil.angelFilter.update(FlxG.elapsed);
			CacheUtil.vcrMario85Filter.update(FlxG.elapsed);
			CacheUtil.ycbuEndingFilter.update(0, FlxG.elapsed);
		});
		#end
	}

	function addEventListeners():Void {
		#if desktop
		// Minimize volume when the window is out of focus
		Application.current.window.onFocusIn.add(() -> {
			// Bring the volume back up when the window is focused again
			var minimizeVolume:Bool = ClientPrefs.getOption('minimizeVolume', Constants.DEFAULT_OPTIONS.get('minimizeVolume'));
			if (minimizeVolume && !CacheUtil.isWindowFocused) {
				// Set back to one decimal place (0.1) when the screen gains focus again
				// (note that if the user had the volume all the way down, it will be set to zero)
				FlxG.sound.volume = (!(Math.abs(FlxG.sound.volume) < FlxMath.EPSILON)) ? 0.1 : 0;
				CacheUtil.isWindowFocused = true;
				// Set the volume back to the last volume used
				FlxTween.num(FlxG.sound.volume, CacheUtil.lastVolumeUsed, 0.3, { type: FlxTweenType.ONESHOT }, (v) -> {
					FlxG.sound.volume = v;
				});
			}
		});
		Application.current.window.onFocusOut.add(() -> {
			// Minimize the volume when the window loses focus
			var minimizeVolume:Bool = ClientPrefs.getOption('minimizeVolume', Constants.DEFAULT_OPTIONS.get('minimizeVolume'));
			if (minimizeVolume && CacheUtil.isWindowFocused) {
				// Set the last volume used to the current volume
				CacheUtil.lastVolumeUsed = FlxG.sound.volume;
				CacheUtil.isWindowFocused = false;
				// Tween the volume to 0.03
				FlxTween.num(FlxG.sound.volume, (!(Math.abs(FlxG.sound.volume) < FlxMath.EPSILON)) ? 0.03 : 0, 0.3, { type: FlxTweenType.ONESHOT }, (v) -> {
					FlxG.sound.volume = v;
				});
			}
		});
		#end

		// Do shit like saving the user's data when the game closes
		Application.current.window.onClose.add(() -> {
			// Save all of the user's data
			SaveUtil.saveAll();
		});
	}

	function registerEntities():Void {
		CacheUtil.registeredEntities.push(new ComplexEntity('test'));
	}
}
