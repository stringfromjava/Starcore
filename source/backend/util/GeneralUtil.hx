package backend.util;

#if DISCORD_ALLOWED
import backend.api.DiscordClient;
#end
import backend.data.Constants;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
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
     * Play menu music ***if*** it hasn't already started.
     */
    public static function playMenuMusic(volume:Float = 1):Void {
        if (CacheUtil.canPlayMenuMusic) {
            FlxG.sound.playMusic(PathUtil.ofMusic(Constants.MENU_MUSIC_NAME), volume, true);
            CacheUtil.canPlayMenuMusic = false;
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
}
