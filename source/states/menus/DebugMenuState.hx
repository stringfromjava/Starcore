package states.menus;

import backend.Controls;
#if FILTERS_ALLOWED
import openfl.filters.ShaderFilter;
#end
import backend.util.CacheUtil;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class DebugMenuState extends FlxState {
    
    var test:FlxText;

    override function create() {
        super.create();

        FlxG.sound.music.stop();
        CacheUtil.canPlayMenuMusic = true;

        #if FILTERS_ALLOWED
        FlxG.game.setFilters([]);
        #end

        test = new FlxText();
        test.text = 'this game is so spoopy OOHHHWHWHWHWHWOOO :ghost:';
        test.size = 48;
        test.updateHitbox();
        test.x = (FlxG.width / 2) - (test.width / 2);
        test.y = (FlxG.height / 2) - (test.height / 2);
        add(test);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            #if FILTERS_ALLOWED
            FlxG.game.setFilters([
                new ShaderFilter(CacheUtil.angelFilter),
                new ShaderFilter(CacheUtil.vcrBorderFilter),
                new ShaderFilter(CacheUtil.vcrMario85Filter),
                new ShaderFilter(CacheUtil.ycbuEndingFilter)
            ]);
            #end
            FlxG.switchState(() -> new MainMenuState());
        }
    }
}
