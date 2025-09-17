package starcore.backend.util;

import flixel.sound.FlxSound;
import flixel.util.FlxSignal;
import lime.media.AudioBuffer;
import lime.media.AudioManager;
import lime.utils.UInt8Array;
import openfl.media.Sound;

/**
 * Type definition for storing sound regeneration data.
 */
#if (windows && cpp)
typedef RegenSoundData =
{
  var sound:FlxSound;
  var isPlaying:Bool;
  var time:Float;
};

/**
 * Utility class for handling the game's audio, such as restarting audio on device change.
 * 
 * THIS WAS NOT MADE BY ME! Credits go to cyn0x8 for this class.
 * @see https://github.com/cyn0x8
 * @see https://github.com/FunkinCrew/Funkin/pull/5569
 */
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
@:nullSafety
final class AudioUtil
{
  #if (windows && cpp)
  /**
   * Signal dispatched when the current audio device is changed, after an attempted restart.
   */
  public static final audioDeviceChangeSignal:FlxSignal = new FlxSignal();

  /**
   * Whether the current audio device has changed.
   */
  static var audioDeviceChanged(get, set):Bool;

  function new() {}

  /**
   * Gets whether the current audio device has changed.
   * 
   * @return If the audio device has changed.
   */
  public static function get_audioDeviceChanged():Bool
  {
    return cast untyped __cpp__('_audioDeviceChanged');
  }

  static function set_audioDeviceChanged(v:Bool):Bool
  {
    untyped __cpp__('_audioDeviceChanged = (bool)v;');
    return v;
  }

  static var initializedAudioFix:Bool = false;

  /**
   * Initializes the audio fix client to handle audio device changes.
   * This should be called once at the start of the application.
   */
  public static function initAudioFix():Void
  {
    if (initializedAudioFix)
    {
      return;
    }

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
  }

  /**
   * Restarts the audio system and regenerates all sounds.
   */
  public static function restartAudio():Void
  {
    final curSounds:Array<FlxSound> = new Array<FlxSound>();

    @:privateAccess
    for (sound in FlxG.sound.list)
    {
      if (sound != null && sound.exists)
      {
        DataUtil.pushUniqueElement(curSounds, sound);
      }
    }
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

    final regenData:Array<RegenSoundData> = new Array<RegenSoundData>();
    for (sound in curSounds)
    {
      regenData.push({sound: sound, isPlaying: sound.playing, time: sound.time});
      sound.pause();
    }

    AudioManager.shutdown();
    AudioManager.init();

    untyped __cpp__('if (curAudioFix != nullptr) curAudioFix->updateCurrentDeviceID();');

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

    // TODO: Do garbage collection here.

    audioDeviceChanged = false;
    audioDeviceChangeSignal.dispatch();
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
  #end
}
