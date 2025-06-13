package starcore.backend.api;

import starcore.backend.data.Constants;
import starcore.backend.util.LoggerUtil;
import starcore.backend.data.ClientPrefs;
#if DISCORD_RPC_ALLOWED
import cpp.RawConstPointer;
import hxdiscord_rpc.Discord;
import hxdiscord_rpc.Types.DiscordRichPresence;
import sys.thread.Thread;
#end
import lime.app.Application;

/**
 * Class that handles Discord rich presence for the client's "Activity" box.
 */
final class DiscordClient
{
	static var presence:DiscordRichPresence = new DiscordRichPresence();

	function new() {}

	/**
	 * Initializes Discord rich presence.
	 */
	public static function initialize():Void
	{
		#if DISCORD_RPC_ALLOWED
		if (ClientPrefs.getOption('discordRPC'))
		{
			// Log info
			LoggerUtil.log('Initializing Discord rich presence');
			// Initialize the client
			Discord.Initialize(Constants.DISCORD_APP_ID, null, true, null);
			// Start the timer (for the amount of time the player has played the game)
			presence.startTimestamp = Math.floor(Sys.time());
			// Start a thread that runs in the background which
			// makes regular callbacks to Discord
			Thread.create(() ->
			{
				// Keep looping until the game exits
				while (true)
				{
					// Set rich presence
					Discord.UpdatePresence(RawConstPointer.addressOf(presence));
					// Update rich presence
					Discord.RunCallbacks();
					// Wait for one second so the game doesn't crash lol
					Sys.sleep(1.0);
				}
			});
		}
		// Add an event listener that shuts down
		// Discord rich presence when the game closes
		Application.current.window.onClose.add(() ->
		{
			shutdown();
		});
		#end
	}

	/**
	 * Shutdowns Discord rich presence.
	 */
	public static function shutdown():Void
	{
		#if DISCORD_RPC_ALLOWED
		LoggerUtil.log('Shutting down Discord rich presence');
		Discord.Shutdown();
		#end
	}
}
