package states.menus;

import flixel.util.FlxSpriteUtil;
import backend.Controls;
import backend.data.ClientPrefs;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import objects.ui.ClickableSprite;

class MainMenuState extends FlxTransitionableState {
    
    var logo:FlxText;
    var test:FlxSprite;

	var buttons:Array<String> = ['play', 'quit'];
	var buttonsGroup:FlxTypedGroup<FlxSprite>;
	var buttonClickFunctions:Map<String, Void->Void>;
	var buttonWasClicked:Bool = false;

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

		buttonsGroup = new FlxTypedGroup<FlxSprite>();
		add(buttonsGroup);

		buttonClickFunctions = [
			'play' => () -> {
				FlxG.switchState(new PlayState());
			},
			'quit' => () -> {
				GeneralUtil.closeGame();
			}
		];

		var newY:Float = 350;
		for (btn in buttons) {
			var coolSwaggerButton:ClickableSprite = new ClickableSprite();
			coolSwaggerButton.loadGraphic(PathUtil.ofImage('menus/main/$btn-button'));
			coolSwaggerButton.scale.set(4, 4);
			coolSwaggerButton.updateHitbox();
			coolSwaggerButton.updateHoverBounds();
			coolSwaggerButton.setPosition(0, newY);
			coolSwaggerButton.onClick = buttonClickFunctions.get(btn);
			coolSwaggerButton.onHover = () -> {
				// Play a sound
				GeneralUtil.playSoundWithEcho(PathUtil.ofSound('blip'), 1, 8);
                FlxSpriteUtil.setBrightness(coolSwaggerButton, 0.3);
			};
			coolSwaggerButton.onHoverLost = () -> {
				if (!buttonWasClicked) {
                    FlxSpriteUtil.setBrightness(coolSwaggerButton, 0);
				}
			};
			buttonsGroup.add(coolSwaggerButton);
			newY += coolSwaggerButton.height + 40;
		}

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
		if (FlxG.keys.justPressed.F11) {
			ClientPrefs.setClientPreference('fullscreen', !ClientPrefs.options.fullscreen);
			trace('Fullscreen is now ${ClientPrefs.options.fullscreen}');
		}

        if (Controls.binds.UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }
}
