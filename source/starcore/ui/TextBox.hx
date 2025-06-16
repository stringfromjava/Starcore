package starcore.ui;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.ui.MouseCursor;
import starcore.backend.data.Constants;
import starcore.backend.util.DataUtil;
import starcore.backend.util.FlixelUtil;

using StringTools;

/**
 * The type of text that a text box is allowed to take.
 * This can be a string, an integer, etc.
 */
enum TextBoxInputType
{
	STRING;
	INT;
	FLOAT;
}

/**
 * UI object which emulates a typical text box field.
 */
class TextBox extends FlxSpriteGroup
{
	//
	// DISPLAY OBJECTS
	// ================================

	/**
	 * The background that is displayed behind the text.
	 */
	public var bg:ClickableSprite;

	/**
	 * The text that the user sees.
	 */
	public var displayText:FlxText;

	/**
	 * The symbol representing where the user is typing.
	 */
	public var cursor:FlxSprite;

	//
	// DATA
	// ===================

	/**
	 * The text the user has typed out.
	 */
	public var text:String = '';

	var type:TextBoxInputType;
	var textHint:String;
	var isFocused:Bool = false;
	var canHoldLetter:Bool = false;
	var canHoldSpace:Bool = false;
	var canHoldBackspace:Bool = false;

	//
	// TIMERS
	// ============================
	var cursorVisibilityTimer:FlxTimer; // For adding a flash on the cursor every half a second
	var delayLetter:FlxTimer; // For preventing any letter (A, COMMA, etc.) being annoying even when only pressed for a split second
	var delaySpace:FlxTimer; // For preventing space being annoying even when only pressed for a split second
	var delayBackspace:FlxTimer; // For preventing backspace being annoying even when only pressed for a split second

	/**
	 * @param x             The X position of `this` text box.
	 * @param y             The Y position of `this` text box.
	 * @param width         The visible width of `this` text box.
	 * @param size          The size of `this` text box.
	 * @param font          The font for the display text. If `null` is passed down, then
	 *                      the default font is used instead.
	 * @param type          The type of text that `this` text box can take. Default value is `TextBoxInputType.STRING`.
	 * @param textHint      A somewhat visible text that (is supposed) to "hint" what
	 *                      the user is supposed to type in the textbox.
	 * @param letterSpacing How much spacing there is in between the text.
	 */
	public function new(x:Float, y:Float, width:Int, size:Int, ?font:String, ?type:TextBoxInputType, textHint:String = '', letterSpacing:Float = 0.0)
	{
		super();

		this.textHint = textHint;
		this.type = (type != null) ? type : STRING;

		bg = new ClickableSprite();
		bg.makeGraphic(1, 1, FlxColor.GRAY);
		bg.behavior.hoverCursor = MouseCursor.IBEAM;
		bg.behavior.resetCursorOnClick = false;
		bg.behavior.onClick = () ->
		{
			isFocused = true;
		};
		add(bg);

		displayText = new FlxText();
		displayText.text = textHint;
		displayText.color = FlxColor.BLACK;
		trace(font);
		displayText.font = font;
		displayText.size = size;
		displayText.fieldWidth = width;
		displayText.wordWrap = false;
		displayText.textField.multiline = false;
		displayText.letterSpacing = letterSpacing;
		add(displayText);

		bg.setGraphicSize(width, Std.int(displayText.height));
		bg.updateHitbox();
		bg.setPosition(x, y);
		displayText.setPosition(x, y);

		cursor = new FlxSprite();
		cursor.makeGraphic(3, Std.int(displayText.height), FlxColor.BLACK);
		cursor.x = displayText.x + displayText.width;
		cursor.y = displayText.y;
		cursor.visible = false;
		add(cursor);

		cursorVisibilityTimer = new FlxTimer();
		cursorVisibilityTimer.start(0.5, (_) ->
		{
			if (isFocused)
			{
				cursor.visible = !cursor.visible;
			}
			else
			{
				cursor.visible = false;
			}
		}, 0);

		delayLetter = new FlxTimer();
		delayLetter.onComplete = (_) ->
		{
			canHoldLetter = true;
		};

		delaySpace = new FlxTimer();
		delaySpace.onComplete = (_) ->
		{
			canHoldSpace = true;
		};

		delayBackspace = new FlxTimer();
		delayBackspace.onComplete = (_) ->
		{
			canHoldBackspace = true;
		};
	}

	//
	// FUNCTION OVERRIDES
	// ======================================

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		// Update the text display
		displayText.text = (text != '') ? text : textHint;
		displayText.alpha = (text != '') ? 1 : 0.5;

		// Update cursor position
		cursor.x = displayText.x + displayText.width;
		cursor.y = displayText.y;

		var lastKeyPressed:FlxKey = FlixelUtil.getLastKeyPressed();
		var currentPressedKeys:Array<FlxKey> = FlixelUtil.getCurrentKeysPressed();
		var allowedKeys:Array<FlxKey> = getAllowedKeysFromType();
		var currentPressedAllowedKeys:Array<FlxKey> = [];
		var currentJustPressedKeys:Array<FlxKey> = FlixelUtil.getCurrentKeysJustPressed();

		for (key in currentPressedKeys)
		{
			var isAllowedChar:Bool = allowedKeys.contains(key);
			if (isAllowedChar)
			{
				currentPressedAllowedKeys.push(key);
			}
		}

		if ((FlxG.mouse.justPressed && !bg.behavior.isHoveringOverMouse()) || lastKeyPressed == FlxKey.ENTER)
		{
			isFocused = false;
			cursor.visible = false;
			resetHolds();
		}

		if (!isFocused || (currentPressedAllowedKeys.length == 0 && currentJustPressedKeys.length == 0))
		{
			resetHolds();
			return;
		}

		// Add all allowed letters that the
		// user is trying to type
		for (key in currentPressedAllowedKeys)
		{
			if (currentJustPressedKeys.contains(key) || canHoldLetter)
			{
				var shift:Bool = ((!FlixelUtil.getCapsLockedEnabled()) ? FlxG.keys.pressed.SHIFT : !FlxG.keys.pressed.SHIFT);
				if (type != STRING && shift)
				{
					// Prevent the user from adding a new character
					// if the type is a number AND the user is holding shift
					continue;
				}
				text += FlixelUtil.convertFlxKeyToChar(key, shift);
			}
		}
		// If any allowed characters are held down, then
		// allow them to be held down
		if (currentPressedAllowedKeys.length > 0)
		{
			if (!delayLetter.active)
			{
				delayLetter.reset(0.5);
			}
		}
		else
		{
			canHoldLetter = false;
			delayLetter.cancel();
		}
		// Add a space if the user presses,
		// well, you know...
		if (FlxG.keys.pressed.SPACE && type == STRING)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				text += ' ';
				delaySpace.reset(0.5);
			}
			else if (canHoldSpace)
			{
				text += ' ';
			}
		}
		else
		{
			canHoldSpace = false;
			delaySpace.cancel();
		}
		// Remove the last character/word from the text
		// if the BACKSPACE key is pressed
		if (FlxG.keys.pressed.BACKSPACE)
		{
			var isPressingCtrl:Bool = FlxG.keys.pressed.CONTROL;
			var textWithRemovedChar:String = text.substring(0, text.length - 1);
			var textWithRemovedWord:String = DataUtil.removeWordFromIndex(text, text.trim().split(' ').length - 1, false);
			if (FlxG.keys.justPressed.BACKSPACE)
			{
				text = (!isPressingCtrl) ? textWithRemovedChar : textWithRemovedWord;
				delayBackspace.reset(0.5);
			}
			else if (canHoldBackspace)
			{
				text = (!isPressingCtrl) ? textWithRemovedChar : textWithRemovedWord;
			}
		}
		else
		{
			canHoldBackspace = false;
			delayBackspace.cancel();
		}
	}

	//
	// GETTERS AND SETTINGS
	// =========================================

	/**
	 * Gets `this` value based on what type it is.
	 * 
	 * @return The proper value based on its type.
	 */
	public function getValue():Dynamic
	{
		if (type == STRING)
		{
			return text;
		}
		else if (type == INT)
		{
			return Std.parseInt(text);
		}
		else if (type == FLOAT)
		{
			return Std.parseFloat(text);
		}
		else
		{
			throw 'Text box has invalid input type: "$type".';
		}
	}

	//
	// CORE FUNCTIONS
	// ==============================

	function resetHolds():Void
	{
		canHoldLetter = false;
		canHoldSpace = false;
		canHoldBackspace = false;
		delayLetter.cancel();
		delaySpace.cancel();
		delayBackspace.cancel();
	}

	function getAllowedKeysFromType():Array<FlxKey>
	{
		switch (type)
		{
			case STRING:
				return Constants.ALLOWED_TEXT_BOX_ALPHABET_CHARACTERS;
			case INT:
				return Constants.ALLOWED_TEXT_BOX_INT_CHARACTERS;
			case FLOAT:
				return Constants.ALLOWED_TEXT_BOX_FLOAT_CHARACTERS;
			default:
				throw 'Text box has invalid input type: "$type".';
		}
	}
}
