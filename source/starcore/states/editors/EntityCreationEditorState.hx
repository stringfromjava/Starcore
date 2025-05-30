package starcore.states.editors;

import flixel.util.FlxColor;
import starcore.backend.data.Constants;
import flixel.ui.FlxButton;
import starcore.objects.states.DebugEditorState;

/**
 * The debug editor for creating new entities. This is where you
 * define the name of the entity, its body parts, how big each body
 * part is, etc.
 */
class EntityCreationEditorState extends DebugEditorState {

	var loadSpriteSheetButton:FlxButton;

	override public function create():Void {

		loadSpriteSheetButton = new FlxButton(10, 10, 'Load Sprite Sheet', () -> {
			trace('bing bong');
		});
		loadSpriteSheetButton.label.color = FlxColor.WHITE;
		loadSpriteSheetButton.label.font = Constants.DEBUG_EDITOR_FONT;
		loadSpriteSheetButton.label.size = 12;
		loadSpriteSheetButton.label.alignment = 'center';
		loadSpriteSheetButton.label.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		loadSpriteSheetButton.updateHitbox();
		loadSpriteSheetButton.setPosition(5, 50);
		add(loadSpriteSheetButton);

		super.create();
	}
}
