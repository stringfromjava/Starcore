package states.menus;

import backend.Controls;
import flixel.tweens.FlxTween;
import backend.util.GeneralUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;

class MainMenuState extends FlxTransitionableState {
    
    var logo:FlxText;

    override function create() {
        super.create();

        // Play menu music
        GeneralUtil.playMenuMusic();

        // Setup the logo
        logo = new FlxText();
		logo.text = 'Starcore';
		logo.size = 300;
		logo.color = FlxColor.WHITE;
		logo.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.GRAY, 8);
		logo.bold = true;
		logo.updateHitbox();
		logo.setPosition((FlxG.width / 2) - (logo.width / 2), 0);
		add(logo);

        FlxTween.num(0, 1, 3, { type: FlxTweenType.ONESHOT }, (v) -> {
            FlxG.sound.volume = v;
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.binds.UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }
}
