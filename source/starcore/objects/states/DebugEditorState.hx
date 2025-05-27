package starcore.objects.states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import starcore.backend.Controls;
import starcore.backend.data.Constants;
import starcore.states.menus.DebugEditorMenuState;

/**
 * Base class for creating a new editor for the debug menu.
 */
abstract class DebugEditorState extends FlxState {

	/**
	 * The name of `this` debug editor.
	 */
	public var name:String;

	/**
	 * The version of `this` debug editor.
	 */
	public var version:String;

	var versionText:FlxText;

	/**
	 * @param name    The name of `this` debug editor (note that "Editor" will be concatenated after it).
	 * @param version The version of `this` debug editor ("v" will be concatenated before it).
	 */
	public function new(name:String, version:String) {
		super();
		this.name = name;
		this.version = version;
	}

	override public function create():Void {
		// TIP: when you call super for your
		// subclass (new editor), it's strongly advised that you
		// call super AFTER you're done creating everything in your
		// subclass so that way everything is layered correctly!
		super.create();

		bgColor = Constants.EDITOR_BACKGROUND_COLOR;

		versionText = new FlxText();
		versionText.text = '$name Editor (v$version)';
		versionText.font = Constants.DEBUG_EDITOR_FONT;
		versionText.size = 25;
		versionText.alpha = 0.5;
		versionText.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		versionText.updateHitbox();
		versionText.setPosition(0, 0);
		add(versionText);
	}

	override public function update(elapsed:Float):Void {
		super.update(elapsed);

		// I added this here so that way you don't have to
		// do this in every editor that extends to this class ;3
		if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
			FlxG.switchState(() -> new DebugEditorMenuState());
		}
	}
}
