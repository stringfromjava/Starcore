package backend.util;

import backend.data.Constants;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.sound.FlxSound;
import flixel.sound.filters.FlxFilteredSound;
import flixel.sound.filters.FlxSoundFilter;
import flixel.sound.filters.effects.FlxSoundReverbEffect;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
#if DISCORD_ALLOWED
import backend.api.DiscordClient;
#end
#if html5
import js.Browser;
#end

/**
 * Utility class which holds functions that don't fit into any other category.
 */
final class GeneralUtil {

    private function new() {}

    /**
     * Fades into a state with a cool transition effect.
     * 
     * @param state             The states to switch to.
     * @param duration          How long it takes to switch from one state to the next state.
     * @param playTransitionSfx Should the game play a sound when it switches states?
     */
    public static function fadeIntoState(state:FlxState, duration:Float, playTransitionSfx:Bool = true):Void {
        if (playTransitionSfx) {
            FlxG.sound.play(PathUtil.ofSound(''), 1, false, false);
        }
        
        FlxG.camera.fade(FlxColor.BLACK, duration, false, () -> {
            FlxG.switchState(state);
        });
    }

	/**
	 * Play a sound with an echo, cave-like sound effect.
	 * 
	 * @param path      The path to the sound to play.
	 * @param volume    The volume of the sound.
	 * @param decayTime How long it echoes for.
	 */
	public static function playSoundWithReverb(path:String, volume:Float = 1, decayTime:Float = 4):Void {
		if (!(CacheUtil.currentEchoSoundsAmount > Constants.REVERB_SOUND_EFFECT_LIMIT)) {
            // Make the sound and filter
            var sound:FlxFilteredSound = new FlxFilteredSound();
            var effect = new FlxSoundReverbEffect();
            // Settings for the echo
            effect.decayTime = decayTime;
            // Load the sound
            sound.loadEmbedded(path);
            sound.filter = new FlxSoundFilter();
            sound.filter.addEffect(effect);
            // Add the sound to the game so that way it
            // gets lowered when the game loses focus and
            // the user has "minimizeVolume" enabled
            FlxG.sound.list.add(sound);
            // Play the sound
            sound.play();
            CacheUtil.currentEchoSoundsAmount++;
            // Recycle the sound after it finishes playing
            new FlxTimer().start((sound.length / 1000) + (decayTime / 1.85), (_) -> {
                sound.filter.clearEffects();
                sound.filter = null;
                FlxG.sound.list.remove(sound, true);
                FlxG.sound.list.recycle(FlxSound);
                sound.destroy();
                CacheUtil.currentEchoSoundsAmount--;
            });
        }
	}

    /**
     * Checks if a name is valid for either an entity or item.
     * 
     * @param name  The name of the entity/item.
     * @return      If the name has no invalid characters. 
     */
     public static function isValidName(name:String):Bool {
        for (i in 0...name.length) {
            var char:String = name.charAt(i);
            if (!Constants.VALID_ITEM_ENTITY_NAME_CHARACTERS.match(char)) {
                return false;
            }
        }
        return true;
    }

    /**
     * Play menu music ***if*** it hasn't already started.
     */
    public static function playMenuMusic(volume:Float = 1):Void {
        if (CacheUtil.canPlayMenuMusic) {
            FlxG.sound.playMusic(PathUtil.ofMusic(Constants.MENU_MUSIC_NAME), volume, true);
            CacheUtil.canPlayMenuMusic = false;
        }
    }

    /**
     * Tweens an `FlxSpriteGroup`'s members with ease.
     * 
     * @param group    The group to tween.
     * @param options  Dynamic object with the attributes to tween.
     * @param duration How long the tween should last for.
     * @param types    The types and eases for the group to tween with.
     */
    public static function tweenSpriteGroup(group:FlxTypedGroup<FlxSprite>, options:Dynamic, duration:Float, types:Dynamic):Void {
        for (obj in group.members) {  
            if (obj != null) {            
                FlxTween.tween(obj, options, duration, types);
            }
        }
    }

    /**
     * Closes the entire game.
     */
    public static function closeGame():Void {
        // Save all of the user's data
        SaveUtil.saveAll();
        // Shutdown Discord rich presence
        #if DISCORD_ALLOWED
        DiscordClient.shutdown();
        #end
        // Close the game respectfully
        #if html5
        Browser.window.close();
        #elseif desktop
        Sys.exit(0);
        #end
    }
}
