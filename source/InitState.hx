import flixel.FlxG;
import flixel.FlxState;
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
		// Set up the system configuration
		flxSystemConfig();

		// Center the window to be in the middle of the display
		Application.current.window.x = Std.int((Application.current.window.display.bounds.width - Application.current.window.width) / 2);
		Application.current.window.y = Std.int((Application.current.window.display.bounds.height - Application.current.window.height) / 2);
	}

	function flxSystemConfig():Void {
		// Set the cursor to be the system default
		FlxG.mouse.useSystemCursor = true;

		// Set auto pause to false
		FlxG.autoPause = false;

		// Set the stage and scaling modes
		Lib.current.stage.align = "tl";
		Lib.current.stage.scaleMode = StageScaleMode.NO_SCALE;

		// Disable the right-click context menu for HTML5
		#if html5
		Browser.document.addEventListener("contextmenu", (e) -> {
			e.preventDefault();
		});
		#end
	}
}