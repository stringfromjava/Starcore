package states.menus;

import backend.Controls;
import backend.data.Constants;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxSpriteUtil;
import flixel.util.FlxTimer;
import objects.ui.ClickableSprite;

class MainMenuState extends FlxTransitionableState {
    
	var logo:FlxText;

	var buttons:Array<String> = ['play', 'quit'];
	var buttonsGroup:FlxTypedGroup<FlxSprite>;
	var buttonClickFunctions:Map<String, Void->Void>;
	var buttonWasClicked:Bool = false;

	var stars:FlxTypedGroup<FlxSprite>;
	var planets:FlxTypedGroup<FlxSprite>;
	var starChangeAlphaTimer:FlxTimer;

    override function create() {
        super.create();

        // Play menu music
        GeneralUtil.playMenuMusic(0);

		// Add the planets in the background
		var newY:Float = 30;
		planets = new FlxTypedGroup<FlxSprite>();
		for (_ in 0...5) {
			var planet:FlxSprite = new FlxSprite();
			var newScale:Float = FlxG.random.float(4, 7);
			planet.loadGraphic(PathUtil.ofImage('bg/bg-planet-${FlxG.random.int(1, 2)}'));
			planet.scale.set(newScale, newScale);
			planet.updateHitbox();
			planet.setPosition(FlxG.random.int(0, FlxG.width), newY);
			FlxSpriteUtil.setBrightness(planet, (newScale / 8.2) * -1);
			planets.add(planet);
			newY += planet.height + 25;
		}
		planets.members.sort((a:FlxSprite, b:FlxSprite) -> {
			var areaA = a.width * a.height;
			var areaB = b.width * b.height;
			if (areaA > areaB) return -1;
			if (areaA < areaB) return 1;
			return 0;
		});
		add(planets);

		// Add the stars in the background
		stars = new FlxTypedGroup<FlxSprite>();
		for (_ in 0...150) {
			var star:FlxSprite = new FlxSprite();
			star.loadGraphic(PathUtil.ofImage('bg/star'));
			star.scale.set(3, 3);
			star.updateHitbox();
			star.setPosition(FlxG.random.int(0, FlxG.width), FlxG.random.int(0, FlxG.height));
			star.alpha = FlxG.random.float(0.3, 1);
			stars.add(star);
		}
		add(stars);

		// Add a timer that changes the alpha of the stars every few seconds
		starChangeAlphaTimer = new FlxTimer();
		starChangeAlphaTimer.start(Constants.STAR_CHANGE_ALPHA_DELAY, (_) -> {
			for (star in stars.members) {
				star.alpha = FlxG.random.float(0.3, 1);
			}
		}, 0);

        // Setup the logo
        logo = new FlxText();
		logo.text = 'Starcore';
		logo.size = 185;
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
		FlxTween.num(0, 1, 3, { type: FlxTweenType.ONESHOT }, (v) -> {
		    FlxG.sound.music.volume = v;
		});
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

		// Update the planets
		for (planet in planets.members) {
			planet.x += Constants.BACKGROUND_PLANET_SCROLL_SPEED;
			if (planet.x > FlxG.width) {
				planet.x = 0 - planet.width;
			}
		}

		// Update the stars
		for (star in stars.members) {
			star.x += Constants.BACKGROUND_STAR_SCROLL_SPEED;
			if (star.x > FlxG.width) {
				star.x = 0 - star.width;
			}
		}

        if (Controls.binds.UI_BACK_JUST_PRESSED) {
            GeneralUtil.closeGame();
        }
    }
}
