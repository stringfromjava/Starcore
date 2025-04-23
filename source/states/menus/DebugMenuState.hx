package states.menus;

import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class DebugMenuState extends FlxState {
    
    var test:FlxText;

    override function create() {
        super.create();
        test = new FlxText();
        test.text = 'this game is so spoopy OOHHHWHWHWHWHWOOO :ghost:';
        test.size = 48;
        test.updateHitbox();
        test.x = (FlxG.width / 2) - (test.width / 2);
        test.y = (FlxG.height / 2) - (test.height / 2);
        add(test);
    }
}
