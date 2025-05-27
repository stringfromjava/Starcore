package starcore.states.menus;

import starcore.backend.data.ClientPrefs;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import starcore.backend.Controls;
import starcore.backend.data.Constants;
import starcore.backend.util.CacheUtil;
import starcore.states.editors.*;
#if FILTERS_ALLOWED
import openfl.filters.ShaderFilter;
#end

/**
 * The state where all the different editors can be access from.
 */
class EditorMenuState extends FlxState {

	var titleText:FlxText;
	var infoText:FlxText;

	override function create():Void {
		super.create();

		CacheUtil.canPlayMenuMusic = true;

		// Set the editor menu background
		FlxG.camera.bgColor = Constants.EDITOR_BACKGROUND_COLOR;

		#if FILTERS_ALLOWED
		FlxG.game.setFilters([]);
		#end

		infoText = new FlxText();
		infoText.text = 'This is where you, the developer, can access multiple editors to \n'
			+ 'accomplish various tasks that otherwise would be difficult to do manually.\n\n\n'
			+ '1: Entity Creation Editor\n\n'
			+ ClientPrefs.getBind('ui_back').toString() + ': Back to Game';
		infoText.font = Constants.DEBUG_EDITOR_FONT;
		infoText.size = 20;
		infoText.setBorderStyle(OUTLINE, FlxColor.BLACK, 1);
		infoText.alignment = CENTER;
		infoText.updateHitbox();
		infoText.screenCenter(XY);
		add(infoText);

		titleText = new FlxText();
		titleText.text = 'Welcome to the Editor Menu';
		titleText.font = Constants.DEBUG_EDITOR_FONT;
		titleText.size = 48;
		titleText.setBorderStyle(OUTLINE, FlxColor.BLACK, 3);
		titleText.updateHitbox();
		titleText.x = (FlxG.width / 2) - (titleText.width / 2);
		titleText.y = (infoText.y - titleText.height) - 50;
		add(titleText);
	}

	override function update(elapsed:Float):Void {
		super.update(elapsed);

		if (FlxG.keys.justPressed.ONE) {
			FlxG.switchState(() -> new EntityCreationEditorState('Entity Creation', Constants.ENTITY_CREATION_EDITOR_VERSION));
		}

		if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
			// Switch back the filters, since we're going
			// back into the main game!
			#if FILTERS_ALLOWED
			FlxG.game.setFilters([
				new ShaderFilter(CacheUtil.angelFilter),
				new ShaderFilter(CacheUtil.vcrBorderFilter),
				new ShaderFilter(CacheUtil.vcrMario85Filter),
				new ShaderFilter(CacheUtil.ycbuEndingFilter)
			]);
			#end
			FlxG.switchState(() -> new MainMenuState());
		}
	}
}
