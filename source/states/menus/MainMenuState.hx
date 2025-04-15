package states.menus;

import backend.util.PathUtil;
import flixel.FlxSprite;
import backend.Controls;
import flixel.tweens.FlxTween;
import backend.util.GeneralUtil;
import flixel.FlxG;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.addons.transition.FlxTransitionableState;

class MainMenuState extends FlxTransitionableState {
    
    var logo:FlxText;
    var test:FlxSprite;

    override function create() {
        super.create();

        // Play menu music
        GeneralUtil.playMenuMusic(0);

        // Setup the logo
        logo = new FlxText();
		logo.text = 'Starcore';
		logo.size = 200;
		logo.color = FlxColor.WHITE;
		logo.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(50, 50, 50), 8);
		logo.updateHitbox();
		logo.setPosition((FlxG.width / 2) - (logo.width / 2), 0);
		add(logo);

        test = new FlxSprite();
        test.loadGraphic(PathUtil.ofImage('test'));
        test.scale.set(0.5, 0.5);
        test.updateHitbox();
        add(test);

        // Slowly bring up the volume for the music
        FlxTween.num(0, 1, 3, { type: FlxTweenType.ONESHOT }, (v) -> {
            FlxG.sound.music.volume = v;
        });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        var speed:Float = 15;

        if (Controls.binds.M_UP_PRESSED) {
            test.y -= speed;
        }
        if (Controls.binds.M_LEFT_PRESSED) {
            test.x -= speed;
        }
        if (Controls.binds.M_DOWN_PRESSED) {
            test.y += speed;
        }
        if (Controls.binds.M_RIGHT_PRESSED) {
            test.x += speed;
        }

        if (Controls.binds.UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }
}
