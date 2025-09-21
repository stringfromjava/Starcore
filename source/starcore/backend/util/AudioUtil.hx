package starcore.backend.util;

import flixel.sound.FlxSound;
import flixel.util.FlxSignal;
import lime.media.AudioBuffer;
import lime.media.AudioManager;
import lime.utils.UInt8Array;
import openfl.media.Sound;

using StringTools;

#if desktop
import sys.io.Process;
#end

/**
 * Utility class for handling the game's audio, such as restarting audio on device change.
 * 
 * THIS WAS NOT MADE BY ME! Credits go to cyn0x8 for this class.
 * @see https://github.com/cyn0x8
 * @see https://github.com/FunkinCrew/Funkin/pull/5569
 */
#if (windows && cpp)
@:buildXml('
<target id="haxe">
  <lib name="ole32.lib" if="windows"/>
</target>
')
@:cppFileCode('
#include <string>
#include "mmdeviceapi.h"

bool _audioDeviceChanged = false;
class AudioFixClient : public IMMNotificationClient {
  public:

  AudioFixClient() : _refCount(1), _pDeviceEnum(nullptr) {
    HRESULT result = CoCreateInstance(__uuidof(MMDeviceEnumerator), nullptr, CLSCTX_INPROC_SERVER, __uuidof(IMMDeviceEnumerator), (void**)&_pDeviceEnum);
    if (result == S_OK) _pDeviceEnum->RegisterEndpointNotificationCallback(this);
    updateCurrentDeviceID();
  }

  ~AudioFixClient() {
    if (_pDeviceEnum != nullptr) {
      _pDeviceEnum->UnregisterEndpointNotificationCallback(this);
      _pDeviceEnum->Release();
      _pDeviceEnum = nullptr;
    }
  }

  HRESULT STDMETHODCALLTYPE OnDefaultDeviceChanged(EDataFlow flow, ERole role, LPCWSTR pwstrDefaultDeviceId) {
    if (flow == eRender && role == eConsole && pwstrDefaultDeviceId != nullptr) {
      if (_currentDeviceID.compare(pwstrDefaultDeviceId) != 0) {
        _audioDeviceChanged = true;
      }
    }

    return S_OK;
  }

  ULONG STDMETHODCALLTYPE AddRef() {
    return InterlockedIncrement(&_refCount);
  }

  ULONG STDMETHODCALLTYPE Release() {
    ULONG ulRef = InterlockedDecrement(&_refCount);
    if (0 == ulRef) delete this;
    return ulRef;
  }

  HRESULT STDMETHODCALLTYPE QueryInterface(REFIID riid, VOID** ppvInterface) {
    if (IID_IUnknown == riid) {
      AddRef();
      *ppvInterface = (IUnknown*)this;
    } else if (__uuidof(IMMNotificationClient) == riid) {
      AddRef();
      *ppvInterface = (IMMNotificationClient*)this;
    } else {
      *ppvInterface = NULL;
      return E_NOINTERFACE;
    }

    return S_OK;
  }

  HRESULT STDMETHODCALLTYPE OnDeviceAdded(LPCWSTR pwstrDeviceId) {
    return S_OK;
  }

  HRESULT STDMETHODCALLTYPE OnDeviceRemoved(LPCWSTR pwstrDeviceId) {
    return S_OK;
  }

  HRESULT STDMETHODCALLTYPE OnDeviceStateChanged(LPCWSTR pwstrDeviceId, DWORD dwNewState) {
    return S_OK;
  }

  HRESULT STDMETHODCALLTYPE OnPropertyValueChanged(LPCWSTR pwstrDeviceId, const PROPERTYKEY key) {
    return S_OK;
  }

  void updateCurrentDeviceID() {
    if (_pDeviceEnum == nullptr) return;
    IMMDevice* _pDevice = nullptr;
    LPWSTR _deviceId = nullptr;
    HRESULT result = _pDeviceEnum->GetDefaultAudioEndpoint(eRender, eConsole, &_pDevice);
    if (SUCCEEDED(result) && _pDevice != nullptr) {
      result = _pDevice->GetId(&_deviceId);
      if (SUCCEEDED(result) && _deviceId != nullptr) {
        _currentDeviceID = _deviceId;
        CoTaskMemFree(_deviceId);
      }

      _pDevice->Release();
    }
  }

  private:

  std::wstring _currentDeviceID;
  IMMDeviceEnumerator* _pDeviceEnum;

  LONG _refCount;
};

AudioFixClient* curAudioFix;
')
#end
#if (mac && cpp)
@:headerCode('
#include <CoreAudio/CoreAudio.h>
extern "C" const char* hx_getDefaultAudioDeviceId();
')
@:cppFileCode('
#include <CoreAudio/CoreAudio.h>
#include <string>
extern "C" const char* hx_getDefaultAudioDeviceId() {
  AudioDeviceID device = kAudioObjectUnknown;
  UInt32 size = sizeof(device);
  AudioObjectPropertyAddress addr = { kAudioHardwarePropertyDefaultOutputDevice, kAudioObjectPropertyScopeGlobal, kAudioObjectPropertyElementMaster };
  OSStatus status = AudioObjectGetPropertyData(kAudioObjectSystemObject, &addr, 0, NULL, &size, &device);
  static char buf[64];
  if (status != noErr) {
    buf[0] = 0;
    return buf;
  }
  // Represent device id as unsigned int string
  snprintf(buf, sizeof(buf), "%u", (unsigned int)device);
  return buf;
}
')
#end
@:nullSafety
final class AudioUtil
{
  /**
   * Signal dispatched when the current audio device is changed, after an attempted restart.
   * Declared unconditionally so platform-specific restart paths can dispatch it.
   */
  public static final onAudioChange:FlxSignal = new FlxSignal();

  #if (windows && cpp)
  /**
   * Whether the current audio device has changed.
   */
  static var audioDeviceChanged(get, set):Bool;

  function new() {}

  static function get_audioDeviceChanged():Bool
  {
    return cast untyped __cpp__('_audioDeviceChanged');
  }

  static function set_audioDeviceChanged(v:Bool):Bool
  {
    untyped __cpp__('_audioDeviceChanged = (bool)v;');
    return v;
  }
  #end

  static var initializedAudioFix:Bool = false;

  // Cross-platform polling state for macOS/Linux.
  #if (mac || linux)
  static var lastDeviceId:String = "";
  static var audioPollTimer:Float = 0.0;
  static inline var POLL_INTERVAL:Float = 1.0;
  #end

  /**
   * Initializes audio fix / polling depending on platform. Safe to call on any platform.
   */
  public static function initAudioFix():Void
  {
    if (initializedAudioFix)
    {
      return;
    }

    #if (windows && cpp)
    // Windows: use IMMNotificationClient-based event callback.
    LoggerUtil.log('Initializing audio device change detection');
    untyped __cpp__('if (curAudioFix == nullptr) curAudioFix = new AudioFixClient();');

    FlxG.signals.preUpdate.add(function():Void
    {
      if (audioDeviceChanged)
      {
        LoggerUtil.log('AUDIO DEVICE CHANGE DETECTED', INFO, false);
        LoggerUtil.log('Restarting audio system');
        restartAudio();
      }
    });
    initializedAudioFix = true;
    return;
    #end

    #if (mac || linux)
    LoggerUtil.log('Initializing audio device polling for macOS/Linux');
    FlxG.signals.preUpdate.add(function():Void
    {
      audioPollTimer += FlxG.elapsed;
      if (audioPollTimer < POLL_INTERVAL)
      {
        return;
      }
      audioPollTimer = 0.0;

      try
      {
        var currentId:String = '';
        #if (mac && cpp)
        try
        {
          var ptr:Dynamic = untyped __cpp__('hx_getDefaultAudioDeviceId()');
          currentId = (ptr == null) ? '' : String(ptr);
        }
        catch (e:Dynamic)
        {
          currentId = '';
        }
        #elseif linux
        try
        {
          var proc:Process = new Process('bash', ['-c', 'pactl info']);
          if (proc.exitCode() == 0)
          {
            var out:String = proc.stdout.readAll().toString();
            proc.close();
            var idx = out.indexOf('Default Sink:');
            if (idx >= 0)
            {
              var line = out.substr(idx, out.indexOf('\n', idx) - idx);
              var parts = line.split(':');
              if (parts.length > 1)
              {
                currentId = parts[1].trim();
              }
            }
            else
            {
              idx = out.indexOf('Default Source:');
              if (idx >= 0)
              {
                var line2 = out.substr(idx, out.indexOf('\n', idx) - idx);
                var parts2 = line2.split(':');
                if (parts2.length > 1)
                {
                  currentId = parts2[1].trim();
                }
              }
            }
          }
          else
          {
            proc.close();
          }
        }
        catch (e:Dynamic)
        {
          currentId = '';
        }
        #end

        if (currentId != '' && currentId != lastDeviceId && lastDeviceId != '')
        {
          LoggerUtil.log('AUDIO DEVICE CHANGE DETECTED', INFO, false);
          LoggerUtil.log('Restarting audio system');
          restartAudio();
        }

        if (currentId != '')
        {
          lastDeviceId = currentId;
        }
      }
      catch (e:Dynamic) {}
    });

    initializedAudioFix = true;
    return;
    #end

    // Other platforms: no-op (function exists so callers don't need to guard)
    initializedAudioFix = true;
  }

  /**
   * Restarts the audio system and attempts to preserve currently-playing sounds.
   */
  public static function restartAudio():Void
  {
    final curSounds:Array<FlxSound> = [];

    for (sound in FlxG.sound.list)
    {
      if (sound != null && sound.exists)
      {
        DataUtil.pushUniqueElement(curSounds, sound);
      }
    }

    if (FlxG.sound.music != null && FlxG.sound.music.exists)
    {
      DataUtil.pushUniqueElement(curSounds, FlxG.sound.music);
    }

    final regenData:Array<Dynamic> = [];
    for (sound in curSounds)
    {
      regenData.push({sound: sound, isPlaying: sound.playing, time: sound.time});
      sound.pause();
    }

    AudioManager.shutdown();
    AudioManager.init();

    #if (windows && cpp)
    // Update the current device id stored in the native helper (if present).
    untyped __cpp__('if (curAudioFix != nullptr) curAudioFix->updateCurrentDeviceID();');
    #end

    for (entry in regenData)
    {
      final sound:FlxSound = entry.sound;
      @:privateAccess regenSound(sound._sound);

      if (entry.isPlaying)
      {
        sound.play(true, entry.time);
      }

      sound.time = entry.time;
    }

    #if (windows && cpp)
    // Reset Windows-only flag
    audioDeviceChanged = false;
    #end

    onAudioChange.dispatch();
  }

  /**
   * Refreshes the sound buffer of a given `Sound`.
   * 
   * @param sound The sound to refresh.
   */
  public static function regenSound(sound:Null<Sound>):Void
  {
    if (sound != null)
    {
      @:privateAccess final curBuffer:Null<AudioBuffer> = sound.__buffer;
      if (curBuffer != null)
      {
        final newBuffer:AudioBuffer = new AudioBuffer();
        newBuffer.bitsPerSample = curBuffer.bitsPerSample;
        newBuffer.channels = curBuffer.channels;
        newBuffer.data = UInt8Array.fromBytes(curBuffer.data.toBytes());
        newBuffer.sampleRate = curBuffer.sampleRate;
        newBuffer.src = curBuffer.src;
        @:privateAccess sound.__buffer = newBuffer;
      }
    }
  }
}
