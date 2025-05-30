package starcore.backend.api;

import starcore.backend.util.LoggerUtil;
#if DISCORD_ALLOWED
import starcore.backend.data.Constants;
import starcore.backend.data.ClientPrefs;
import flixel.FlxG;
import cpp.RawConstPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types.DiscordRichPresence;
import lime.app.Application;
import sys.thread.Thread;

/**
 * Class that handles Discord rich presence for the client's
 * "Activity" box.
 */
final class DiscordClient {

	private static var _presence:DiscordRichPresence = new DiscordRichPresence();
	private static var _appId:String = '1361513332883980309'; // ID for the Discord application

	private function new() {}

	/**
	 * Initializes Discord rich presence.
	 */
	public static function initialize():Void {
		if (ClientPrefs.getOption('discordRPC')) {
			// Log info
			LoggerUtil.log('Initializing Discord rich presence');
			// Initialize the client
			Discord.Initialize(_appId, null, true, null);
			// Start the timer (for the amount of time the player has played the game)
			_presence.startTimestamp = Math.floor(Sys.time());
			// Start a thread that runs in the background which
			// makes regular callbacks to Discord
			Thread.create(() -> {
				// Keep looping until the game exits
				while (true) {
					// Set rich presence
					Discord.UpdatePresence(RawConstPointer.addressOf(_presence));
					// Update rich presence
					Discord.RunCallbacks();
					// Wait for one second so the game doesn't crash lol
					Sys.sleep(1.0);
				}
			});
		}
		// Add an event listener that shuts down Discord rich presence
		// when the game closes
		Application.current.window.onClose.add(() -> {
			shutdown();
		});
	}

	/**
	 * Shutdowns Discord rich presence.
	 */
	public static function shutdown():Void {
		LoggerUtil.log('Shutting down Discord rich presence');
		Discord.Shutdown();
	}
}
#end
