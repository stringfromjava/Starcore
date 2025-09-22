package starcore.backend.util;

import haxe.PosInfos;
import starcore.backend.data.Constants;
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
    // Create the new logging file.
    var currentDate:String = DateTools.format(Date.now(), '%Y-%m-%d %H-%M-%S');
    var logsFolder:String = 'logs';

    // Make sure the logs folder exists.
    if (!FileSystem.exists(logsFolder))
    {
      FileSystem.createDirectory(logsFolder);
    }

    // Create the new log file.
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
   * @param infos       Additional information about the log. This is automatically filled in by the compiler.
   */
  public static inline function log(info:Dynamic, logType:LogType = INFO, includeDots:Bool = true, ?infos:PosInfos):Void
  {
    writeInfo('$info${includeDots ? '...' : ''}', logType, infos);
  }

  /**
   * Write info to the console and the log file as an info log.
   * 
   * @param info        The information to log.
   * @param includeDots Whether or not to add dots (`...`) at the end of a log.
   *                    By default this is true.
   * @param infos       Additional information about the log. This is automatically filled in by the compiler.
   */
  public static inline function info(info:Dynamic, includeDots:Bool = true, ?infos:PosInfos):Void
  {
    writeInfo('$info${includeDots ? '...' : ''}', INFO, infos);
  }

  /**
   * Write info to the console and the log file as a warning log.
   * 
   * @param info        The information to log.
   * @param includeDots Whether or not to add dots (`...`) at the end of a log.
   *                    By default this is true.
   * @param infos       Additional information about the log. This is automatically filled in by the compiler.
   */
  public static inline function warn(info:Dynamic, includeDots:Bool = true, ?infos:PosInfos):Void
  {
    writeInfo('$info${includeDots ? '...' : ''}', WARNING, infos);
  }

  /**
   * Write info to the console and the log file as an error log.
   * 
   * @param info        The information to log.
   * @param includeDots Whether or not to add dots (`...`) at the end of a log.
   *                    By default this is true.
   * @param infos       Additional information about the log. This is automatically filled in by the compiler.
   */
  public static inline function error(info:Dynamic, includeDots:Bool = false, ?infos:PosInfos):Void
  {
    writeInfo('$info${includeDots ? '...' : ''}', ERROR, infos);
  }

  /**
   * The main function that writes the log to a file and the console.
   * This is also the function that replaces the default `trace()` function.
   * 
   * @param logMsg  The message to log.
   * @param logType The type of log that is being displayed. This also affects the color in the console.
   * @param infos   Additional information about the log. This is automatically filled in by the compiler.
   */
  public static function writeInfo(logMsg:String, logType:LogType = INFO, ?infos:PosInfos):Void
  {
    var timestamp:String = Date.now().toString();
    var className:String = infos?.className ?? 'UnknownClass';
    var methodName:String = infos?.methodName ?? 'unknownMethod';
    var lineNumber:Int = infos?.lineNumber ?? 0;
    var color:String = switch (logType)
    {
      case INFO: ''; // Just simple, plain white.
      case WARNING: Constants.YELLOW;
      case ERROR: Constants.RED;
    };

    var flog:String = '$timestamp [${logType}] [${className}.${methodName}():${lineNumber}] $logMsg'; // Log written to the current log file.
    var log:String = '${Constants.BOLD}$color$timestamp [${logType}] [${className}.${methodName}():${lineNumber}]${Constants.RESET}$color $logMsg${Constants.RESET}';
    #if LOGGING_ALLOWED
    try
    {
      file.writeString('$flog\n');
      file.flush();
    }
    catch (e:Exception)
    {
      // Can't write to file, move on.
    }
    #end
    switch (logType)
    {
      case INFO:
        FlxG.log.add(flog);
      case WARNING:
        FlxG.log.warn(flog);
      case ERROR:
        FlxG.log.error(flog);
    }

    #if (sys || nodejs)
    Sys.println(log);
    #elseif js
    js.Browser.console.log(log);
    #else
    trace(log);
    #end
  }
}
