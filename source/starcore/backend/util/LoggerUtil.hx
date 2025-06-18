package starcore.backend.util;

#if LOGGING_ALLOWED
import haxe.Exception;
import sys.FileSystem;
import sys.io.File;
import sys.io.FileOutput;
#end

/**
 * The types of logs.
 */
enum LogType
{
	INFO;
	WARNING;
	ERROR;
}

/**
 * Utility class for displaying logs in the console and
 * in a `.txt` file in the game's `log` folder.
 * 
 * If you would like to find all created log files, they will be located in the
 * folder where the executable is located (aka, the `bin` folder where
 * the game's output is compiled to).
 */
final class LoggerUtil
{
	#if LOGGING_ALLOWED
	static var file:FileOutput;
	#end

	function new() {}

	/**
	 * Setup Starcore's logging system. Note that this is
	 * ***ONLY*** used when Starcore is in its initializing state!
	 * 
	 * This function does nothing if the conditional `LOGGING_ALLOWED` is disabled.
	 */
	public static function initialize():Void
	{
		#if LOGGING_ALLOWED
		// Create the new logging file
		var currentDate:String = DateTools.format(Date.now(), '%Y-%m-%d %H-%M-%S');
		var logsFolder:String = 'logs';

		// Make sure the logs folder exists
		if (!FileSystem.exists(logsFolder))
		{
			FileSystem.createDirectory(logsFolder);
		}

		// Create the new log file
		file = File.write('$logsFolder/$currentDate.txt', true);
		#end
	}

	/**
	 * Shutdown Starcore's logging system. Note that this is
	 * ***ONLY*** used when Starcore gets closed!
	 * 
	 * This function does nothing if the conditional `LOGGING_ALLOWED` is disabled.
	 */
	public static function shutdown():Void
	{
		log('Shutting down logging system');
		#if LOGGING_ALLOWED
		file.flush();
		file.close();
		#end
	}

	/**
	 * Log basic info into the console and the log file.
	 * 
	 * This function does not write to a file and instead
	 * only traces the message in the console if the conditional `LOGGING_ALLOWED` is disabled.
	 * 
	 * @param info        The information to log.
	 * @param logType     The type of log to be displayed. This is just regular info by default.
	 * @param includeDots Whether or not to add dots (`...`) at the end of a log.
	 *                    By default this is true.
	 */
	public static inline function log(info:Dynamic, logType:LogType = INFO, includeDots:Bool = true):Void
	{
		writeInfo('$info${includeDots ? '...' : ''}', logType);
	}

	static function writeInfo(logMsg:String, logType:LogType = INFO):Void
	{
		var timestamp:String = Date.now().toString();
		var newLog:String = '[STARCORE][$logType][$timestamp]: $logMsg';
		#if LOGGING_ALLOWED
		try
		{
			file.writeString('$newLog\n');
			file.flush();
		}
		catch (e:Exception)
		{
			// Can't write to file, move on
		}
		#end
		trace(newLog);
	}
}
