package starcore.ui;

import flixel.util.FlxTimer;
import flixel.FlxSprite;
import starcore.backend.util.DataUtil;
import starcore.backend.data.Constants;
import flixel.FlxG;
import starcore.backend.util.FlixelUtil;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import openfl.ui.MouseCursor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

using StringTools;

/**
 * The type of text that a text box is allowed to take.
 * This can be a string, an integer, etc.
 */
enum TextBoxInputType
{
	STRING;
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

	var textHint:String;
	var isFocused:Bool = false;
	var canHoldLetter:Bool = false;
	var canHoldSpace:Bool = false;
	var canHoldBackspace:Bool = false;

	//
	// TIMERS
	// ============================
	var cursorVisibilityTimer:FlxTimer; // For adding a flash every half a second
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
	 * @param type          The type of text that `this` text box can take.
	 * @param textHint      A somewhat visible text that (is supposed) to "hint" what
	 *                      the user is supposed to type in the textbox.
	 * @param letterSpacing How much spacing there is in between the text.
	 */
	public function new(x:Float, y:Float, width:Int, size:Int, ?font:String, type:TextBoxInputType = STRING, textHint:String = '', letterSpacing:Float = 0.0)
	{
		super();

		this.textHint = textHint;

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
		displayText.font = font;
		displayText.size = size;
		displayText.alpha = 0.5;
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
		var currentPressedValidKeys:Array<FlxKey> = []; // Only characters like THREE, COMMA, etc.
		var currentJustPressedKeys:Array<FlxKey> = FlixelUtil.getCurrentKeysJustPressed();

		for (key in currentPressedKeys)
		{
			var isAllowedChar:Bool = Constants.ALLOWED_TEXT_BOX_CHARACTERS.contains(key);
			if (isAllowedChar)
			{
				currentPressedValidKeys.push(key);
			}
		}

		if ((FlxG.mouse.justPressed && !bg.behavior.isHoveringOverMouse()) || lastKeyPressed == FlxKey.ENTER)
		{
			isFocused = false;
			cursor.visible = false;
			resetHolds();
		}

		if (!isFocused)
		{
			resetHolds();
			return;
		}

		if (currentPressedKeys.length == 0 && currentJustPressedKeys.length == 0)
		{
			resetHolds();
			return;
		}

		// Add all regular letters that the
		// user is trying to type
		for (key in currentPressedKeys)
		{
			var isAllowedChar:Bool = Constants.ALLOWED_TEXT_BOX_CHARACTERS.contains(key);
			if (!isAllowedChar)
			{
				continue;
			}

			if (currentJustPressedKeys.contains(key) || canHoldLetter)
			{
				text += FlixelUtil.convertFlxKeyToChar(key, FlxG.keys.pressed.SHIFT);
			}
		}

		if (currentPressedValidKeys.length > 0)
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
		if (FlxG.keys.pressed.SPACE)
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

	function resetHolds():Void
	{
		canHoldLetter = false;
		canHoldSpace = false;
		canHoldBackspace = false;
		delayLetter.cancel();
		delaySpace.cancel();
		delayBackspace.cancel();
	}
}
