package starcore.ui;

import starcore.backend.data.Constants;
import flixel.FlxG;
import starcore.backend.util.FlixelUtil;
import flixel.input.keyboard.FlxKey;
import flixel.util.FlxColor;
import openfl.ui.MouseCursor;
import flixel.text.FlxText;
import flixel.group.FlxSpriteGroup;

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
	/**
	 * The background that is displayed behind the text.
	 */
	public var bg:ClickableSprite;

	//
	// DATA
	// ===================
	var text:String = ''; // The text the user has typed out
	var isFocused:Bool = false;

	//
	// DISPLAY OBJECTS
	// ================================
	var displayText:FlxText; // The text that the user sees

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

		bg = new ClickableSprite();
		bg.makeGraphic(1, 1, FlxColor.GRAY);
		bg.behavior.hoverCursor = MouseCursor.IBEAM;
		bg.behavior.onClick = () ->
		{
			isFocused = true;
		};
		add(bg);

		displayText = new FlxText();
		displayText.text = textHint;
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
	}

	//
	// FUNCTION OVERRIDES
	// ======================================

	override function update(elapsed:Float):Void
	{
		super.update(elapsed);

		if (FlxG.mouse.justPressed && !bg.behavior.isHoveringOverMouse())
		{
			isFocused = false;
		}

		if (!isFocused)
		{
			return;
		}

		var lastKeyPressed:FlxKey = FlixelUtil.getLastKeyPressed();
		var isAllowedChar:Bool = Constants.ALLOWED_TEXT_BOX_CHARACTERS.contains(lastKeyPressed);

		if (lastKeyPressed == FlxKey.NONE)
		{
			return;
		}

		// Check if the user is pressing SHIFT
		if (FlxG.keys.pressed.SHIFT && isAllowedChar)
		{
			trace(FlixelUtil.convertFlxKeyToChar(lastKeyPressed, true));
		}
		else
		{
			trace(FlixelUtil.convertFlxKeyToChar(lastKeyPressed));
		}
	}
}
