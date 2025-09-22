package;

import flixel.FlxState;
import flixel.math.FlxMath;
import flixel.system.FlxAssets;
import lime.app.Application;
import openfl.Lib;
import openfl.display.StageQuality;
import openfl.display.StageScaleMode;
import starcore.backend.api.DiscordClient;
import starcore.backend.data.ClientPrefs;
import starcore.backend.util.AudioUtil;
import starcore.backend.util.LoggerUtil;
import starcore.backend.util.PathUtil;
#if debug
import starcore.menus.MainMenuState;
#else
import starcore.menus.PSXStartupMenuState;
#end
#if web
import js.Browser;
#end
#if (web && debug)
import openfl.events.KeyboardEvent;
import starcore.backend.util.SaveUtil;
#end

/**
 * The initial state of the game. This is where
 * you can load assets and set up the game.
 */
class InitState extends FlxState
{
  /**
   * The volume used when the window is out of focus.
   */
  static final MINIMIZED_VOLUME:Float = 0.015;

  /**
   * The duration of the volume tweening.
   */
  static final TWEEN_DURATION:Float = 0.45;

  /**
   * A tween for the volume when the window
   * loses focus and gains focus again.
   */
  static var volumeTween:FlxTween = null;

  /**
   * The last volume the user had before the game lost focus.
   */
  static var lastVolume:Float = 1.0;

  /**
   * Is the game's window currently focused?
   */
  static var isWindowFocused:Bool = true;

  override function create():Void
  {
    super.create();

    // Initialize lastVolume from saved data or current sound volume.
    if (FlxG.save.data != null && Reflect.hasField(FlxG.save.data, 'volume'))
    {
      lastVolume = FlxG.save.data.volume;
    }
    else
    {
      lastVolume = FlxG.sound.volume;
    }

    // Setup the logger for Starcore.
    LoggerUtil.initialize();

    info('INITIALIZING STARCORE SETUP', false);

    // Load all of the player's settings and options.
    // Note that if this line is not present, it will
    // cause null errors and crash the game!
    ClientPrefs.loadAll();

    // Configure and setup the Audio utility class.
    AudioUtil.initAudioFix();

    // Configure the global manager class Starcore uses.
    StarcoreG.configure();

    // Assign and configure Flixel settings.
    configureFlixelSettings();

    // Add the processes that always run in the background.
    addBackgroundProcesses();

    // Add the event listeners.
    addEventListeners();

    // Register all of the entities that are in the game.
    registerEntities();

    // Start up Discord rich presence.
    DiscordClient.initialize();

    // Switch to the main menu state after everything has loaded.
    LoggerUtil.log('Setup complete! Switching to main menu');
    FlxG.switchState(() -> #if !debug new PSXStartupMenuState() #else new MainMenuState() #end);
  }

  function configureFlixelSettings():Void
  {
    LoggerUtil.log('Configuring Flixel settings');

    // Set the cursor to be the system default, rather than using a custom cursor.
    // TODO: Maybe use a custom cursor (that isn't Flixel's)?
    FlxG.mouse.useSystemCursor = true;

    // Set auto pause to false (we NEVER want this enabled).
    FlxG.autoPause = false;

    // Set the stage and scaling modes.
    Lib.current.stage.align = 'tl';
    Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

    // Disable the binds for increasing/decreasing/muting the Flixel master volume.
    FlxG.sound.volumeUpKeys = [];
    FlxG.sound.volumeDownKeys = [];
    FlxG.sound.muteKeys = [];

    // Set the default font.
    FlxAssets.FONT_DEFAULT = PathUtil.ofFont('Born2bSportyFS');

    // Set the stage quality.
    #if !web
    FlxG.stage.quality = StageQuality.LOW;
    #else
    FlxG.stage.quality = StageQuality.MEDIUM;
    #end

    // Make the window borderless when it is not in fullscreen mode.
    // TODO: Figure out how to make it draggable.
    #if desktop
    Application.current.window.borderless = true;
    #end

    // Disable the right-click context menu for HTML5.
    #if web
    Browser.document.addEventListener('contextmenu', (e) ->
    {
      e.preventDefault();
    });
    #end

    // Configure the event listener for detecting caps lock if the target is set to HTML5.
    #if web
    untyped __js__('
      window.__haxe_capslock__ = false;
      document.addEventListener("keydown", function (e) {
        if (e.getModifierState) {
          window.__haxe_capslock__ = e.getModifierState("CapsLock");
        }
      });
    ');
    #end
  }

  function addBackgroundProcesses():Void {}

  function addEventListeners():Void
  {
    LoggerUtil.log('Adding event listeners');

    // Minimize volume when the window is out of focus.
    #if desktop
    Application.current.window.onFocusIn.add(() ->
    {
      // Bring the volume back up when the window is focused again.
      if (ClientPrefs.options.minimizeVolume && !isWindowFocused)
      {
        // Cancel any ongoing tween
        if (volumeTween != null)
        {
          volumeTween.cancel();
          volumeTween = null;
        }

        // Smoothly tween from current (minimized) volume back to lastVolume
        volumeTween = FlxTween.num(FlxG.sound.volume, lastVolume, TWEEN_DURATION, null, (v:Float) ->
        {
          FlxG.sound.volume = v;
        });
        volumeTween.onComplete = (_) ->
        {
          lastVolume = FlxG.sound.volume;
        };
        isWindowFocused = true;
      }
    });
    Application.current.window.onFocusOut.add(() ->
    {
      // Minimize the volume when the window loses focus.
      if (ClientPrefs.options.minimizeVolume && isWindowFocused)
      {
        // Store the current (user) volume so we can restore it later.
        lastVolume = FlxG.sound.volume;

        var isMuted:Bool = FlxG.sound.muted || (Math.abs(FlxG.sound.volume) < FlxMath.EPSILON) || FlxG.sound.volume == 0;

        if (volumeTween != null)
        {
          volumeTween.cancel();
          volumeTween = null;
        }

        // Tween to a very low volume (or zero if already muted).
        volumeTween = FlxTween.num(FlxG.sound.volume, !isMuted ? MINIMIZED_VOLUME : 0, TWEEN_DURATION, null, (v:Float) ->
        {
          FlxG.sound.volume = v;
        });
        isWindowFocused = false;
      }
    });
    // Save the volume the user originally had, just in
    // case they close the game while it's out of focus.
    Application.current.window.onClose.add(() ->
    {
      FlxG.save.data.mute = FlxG.sound.muted;
      FlxG.save.data.volume = lastVolume;
      FlxG.save.flush();
    });
    #end

    // Delete all save data if CTRL + BACKSPACE
    // is pressed on debug mode in the web version.
    #if (web && debug)
    FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, (_) ->
    {
      if (FlxG.keys.pressed.CONTROL && FlxG.keys.justPressed.BACKSPACE)
      {
        SaveUtil.deleteAll();
      }
    });
    #end

    // Do shit like saving the user's data when the game closes.
    Application.current.window.onClose.add(() ->
    {
      StarcoreG.closeGame(false);
    });
  }

  function registerEntities():Void {}
}
