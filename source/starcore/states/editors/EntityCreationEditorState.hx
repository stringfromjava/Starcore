package starcore.states.editors;

import starcore.backend.util.AssetUtil;
import openfl.Assets;
import flixel.FlxSprite;
import starcore.backend.util.LoggerUtil;
import lime.app.Event;
import lime.ui.FileDialogType;
import lime.ui.FileDialog;
import flixel.util.FlxColor;
import starcore.backend.data.Constants;
import flixel.ui.FlxButton;
import starcore.objects.states.DebugEditorState;

using StringTools;

/**
 * The debug editor for creating new entities. This is where you
 * define the name of the entity, its body parts, how big each body
 * part is, etc.
 */
class EntityCreationEditorState extends DebugEditorState {

	var loadSpriteSheetButton:FlxButton;
	var test:FlxSprite;

	override public function create():Void {
		createButtons();

		test = new FlxSprite();
		test.setPosition(0, 0);
		add(test);

		super.create();
	}

	function createButtons():Void {
		loadSpriteSheetButton = new FlxButton('Load Sprite Sheet', () -> {
			LoggerUtil.log('Attempting to open a sprite sheet');
			var dialog:FileDialog = new FileDialog();
			var onSelectEvent:Event<String->Void> = new Event<String->Void>();

			onSelectEvent.add((path:String) -> {
				// Modify the path passed down and replace all
				// back slashes (\) with slashes (/)
				var p:String = path.replace('\\', '/');
				LoggerUtil.log('File Opened -> $p', false);

				// Convert the chosen entity's pathways into a
				// pathway that HaxeFlixel can accept (in the assets folder)
				LoggerUtil.log('Converting pathway into path to game entity textures folder');
				var assetsDir:String = 'assets/entities/textures/';
				var fileName:String = AssetUtil.removeFileExtension(p.split('/').pop());
				var destPathPng:String = '$assetsDir$fileName.png';
				var destPathXml:String = '$assetsDir$fileName.xml';
				LoggerUtil.log('Path "$p" was converted to "$destPathPng"', false);
				LoggerUtil.log('Path "$p" was converted to "$destPathXml"', false);

				// Log and check if the .png asset is valid
				if (Assets.exists(destPathPng)) {
					LoggerUtil.log('Entity spritesheet "$destPathPng" was successfully loaded.', false);
					test.loadGraphic(destPathPng);
				} else {
					LoggerUtil.log('Entity spritesheet "$destPathPng" is not cached! Add the entity\'s .png file in '
						+ '"assets/entities/textures/" to properly load the entity\'s spritesheet.',
						WARNING, false);
				}

				// Log and check if the .xml asset is valid
				if (Assets.exists(destPathXml)) {
					LoggerUtil.log('Entity format "$destPathXml" was successfully loaded.', false);
				} else {
					LoggerUtil.log('Entity format "$destPathXml" is not cached! Add the entity\'s .xml file in '
						+ '"assets/entities/textures/" to properly load the entity\'s format.',
						WARNING, false);
				}
			});
			dialog.onSelect = onSelectEvent;
			dialog.browse(FileDialogType.OPEN, 'png', null, 'Open a sprite sheet');
		});
		loadSpriteSheetButton.makeGraphic(50, 20, FlxColor.fromRGB(80, 80, 80));
		loadSpriteSheetButton.updateHitbox();
		loadSpriteSheetButton.setPosition(5, 50);
		loadSpriteSheetButton.label.color = FlxColor.WHITE;
		loadSpriteSheetButton.label.font = Constants.DEBUG_EDITOR_FONT;
		loadSpriteSheetButton.label.size = 12;
		loadSpriteSheetButton.label.alignment = 'center';
		loadSpriteSheetButton.label.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		add(loadSpriteSheetButton);
	}
}
