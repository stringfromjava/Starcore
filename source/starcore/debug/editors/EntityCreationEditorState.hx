package starcore.debug.editors;

import starcore.ui.TextBox;
import flixel.util.FlxColor;
import starcore.backend.util.PathUtil;
import flixel.FlxG;
import starcore.backend.data.Constants;
import lime.ui.FileDialogType;
import openfl.utils.Assets;
import starcore.backend.util.AssetUtil;
import lime.app.Event;
import lime.ui.FileDialog;
import starcore.backend.util.LoggerUtil;
import starcore.ui.ClickableText;

using StringTools;

/**
 * The debug editor for creating new entities. This is where you
 * define the name of the entity, its body parts, how big each body
 * part is, etc.
 */
class EntityCreationEditorState extends DebugEditorState
{
	var loadSpriteSheetButton:ClickableText;
	var currentLoadedPath:String = '';
	var test:TextBox;

	//
	// METHOD OVERRIDES
	// =========================================

	function createStage():Void {}

	function createUI():Void
	{
		setupButtons();
	}

	//
	// SETUP FUNCTIONS
	// ================================

	function setupButtons():Void
	{
		loadSpriteSheetButton = new ClickableText();
		loadSpriteSheetButton.text = 'Load Sprite Sheet';
		loadSpriteSheetButton.size = 32;
		loadSpriteSheetButton.font = Constants.DEBUG_EDITOR_FONT;
		loadSpriteSheetButton.setBorderStyle(OUTLINE, FlxColor.BLACK, 2);
		loadSpriteSheetButton.updateHitbox();
		loadSpriteSheetButton.setPosition(10, 50);
		loadSpriteSheetButton.behavior.onClick = () ->
		{
			LoggerUtil.log('Attempting to open a sprite sheet');
			var dialog:FileDialog = new FileDialog();
			var onSelectEvent:Event<String->Void> = new Event<String->Void>();

			onSelectEvent.add((path:String) ->
			{
				// Modify the path passed down and replace all
				// back slashes (\) with slashes (/)
				var p:String = path.replace('\\', '/');
				LoggerUtil.log('File Opened -> $p', false);

				// Convert the chosen entity's pathways into a
				// pathway that HaxeFlixel can accept (in the assets folder)
				LoggerUtil.log('Converting pathway into path to game entity textures folder');
				var assetsDir:String = 'assets/entities/textures/';
				var fileName:String = AssetUtil.removeFileExtension(p.split('/').pop());
				currentLoadedPath = '$assetsDir$fileName';
				var destPathPng:String = '$currentLoadedPath.png';
				var destPathXml:String = '$currentLoadedPath.xml';
				LoggerUtil.log('Path "$p" was converted to "$destPathPng"', false);
				LoggerUtil.log('Path "$p" was converted to "$destPathXml"', false);

				// Log and check if the .png asset is valid
				if (Assets.exists(destPathPng))
				{
					LoggerUtil.log('Entity spritesheet "$destPathPng" was successfully loaded.', false);
				}
				else
				{
					LoggerUtil.log('Entity spritesheet "$destPathPng" is not cached! Add the entity\'s .png file in '
						+ '"assets/entities/textures/" to properly load the entity\'s spritesheet.',
						WARNING, false);
				}

				// Log and check if the .xml asset is valid
				if (Assets.exists(destPathXml))
				{
					LoggerUtil.log('Entity format "$destPathXml" was successfully loaded.', false);
				}
				else
				{
					LoggerUtil.log('Entity format "$destPathXml" is not cached! Add the entity\'s .xml file in '
						+ '"assets/entities/textures/" to properly load the entity\'s format.',
						WARNING, false);
				}
			});
			dialog.onSelect = onSelectEvent;
			dialog.browse(FileDialogType.OPEN, 'png', null, 'Open a sprite sheet');
		};
		loadSpriteSheetButton.behavior.onHover = () ->
		{
			loadSpriteSheetButton.underline = true;
			FlxG.sound.play(PathUtil.ofSharedSound('blip'));
		};
		loadSpriteSheetButton.behavior.onHoverLost = () ->
		{
			loadSpriteSheetButton.underline = false;
		};
		add(loadSpriteSheetButton);

		test = new TextBox(300, 400, 300, 16, Constants.DEBUG_EDITOR_FONT, null, 'Type something OwO');
		add(test);
		add(new TextBox(300, 450, 300, 16, Constants.DEBUG_EDITOR_FONT, STRING, 'Type some text...'));
		add(new TextBox(300, 500, 300, 16, Constants.DEBUG_EDITOR_FONT, INT, 'Type an integer...'));
		add(new TextBox(300, 550, 300, 16, Constants.DEBUG_EDITOR_FONT, FLOAT, 'Type a number...'));
	}
}
