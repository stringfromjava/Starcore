package states.menus;

import backend.Controls;
import backend.util.WorldUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import objects.background.BackgroundPlanet;
import objects.background.BackgroundStar;
import objects.ui.ClickableSprite;

/**
 * State that represents the main menu of the game.
 * This is where the player can start a new game, load a game, or quit the game.
 */
class MainMenuState extends FlxTransitionableState {
    
	var logo:FlxText;

	var buttons:Array<String> = ['play', 'quit'];
	var buttonsGroup:FlxTypedGroup<FlxSprite>;
	var buttonClickFunctions:Map<String, Void->Void>;
	var buttonWasClicked:Bool = false;

	var stars:FlxTypedGroup<BackgroundStar>;
	var planets:FlxTypedGroup<BackgroundPlanet>;
	var starChangeAlphaTimer:FlxTimer;

    override function create() {
        super.create();

        // Play menu music
        GeneralUtil.playMenuMusic();

		// Add the planets in the background
		var newY:Float = 30;
		planets = WorldUtil.generatePlanets();
		add(planets);

		// Add the stars in the background
		stars = WorldUtil.generateStars();
		add(stars);

        // Setup the logo
        logo = new FlxText();
		logo.text = 'STARCORE';
		logo.size = 185;
		logo.color = FlxColor.WHITE;
		logo.setBorderStyle(FlxTextBorderStyle.SHADOW, FlxColor.fromRGB(50, 50, 50), 8);
		logo.updateHitbox();
		logo.setPosition((FlxG.width / 2) - (logo.width / 2), 0);
		add(logo);

		// Setup the main menu buttons
		buttonsGroup = new FlxTypedGroup<FlxSprite>();
		add(buttonsGroup);

		buttonClickFunctions = [
			'play' => () -> {
				FlxG.sound.music.stop();
				FlxG.switchState(new PlayState());
			},
			'quit' => () -> {
				GeneralUtil.closeGame();
			}
		];
		
		var newY:Float = 350;  // Change this to the starting Y position for the menu buttons
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
				GeneralUtil.playSoundWithReverb(PathUtil.ofSound('blip'), 1);
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
		// FlxTween.num(0, 1, 3, { type: FlxTweenType.ONESHOT }, (v) -> {
		//     FlxG.sound.music.volume = v;
		// });
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

		#if EDITORS_ALLOWED
		if (FlxG.keys.justPressed.F7) {
			FlxG.switchState(() -> new DebugMenuState());
		}
		#end

        if (Controls.binds.UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }
}
