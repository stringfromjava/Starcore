package starcore.states.menus;

import starcore.backend.data.Constants;
import starcore.states.editors.*;
import starcore.backend.Controls;
#if FILTERS_ALLOWED
import openfl.filters.ShaderFilter;
#end
import starcore.backend.util.CacheUtil;
import flixel.FlxG;
import flixel.text.FlxText;
import flixel.FlxState;

class DebugMenuState extends FlxState {

	var test:FlxText;

	override function create():Void {
		super.create();

		CacheUtil.canPlayMenuMusic = true;

		#if FILTERS_ALLOWED
		FlxG.game.setFilters([]);
		#end

		test = new FlxText();
		test.text = 'this game is so spoopy OOHHHWHWHWHWHWOOO :ghost:';
		test.font = Constants.DEBUG_EDITOR_FONT;
		test.size = 48;
		test.updateHitbox();
		test.x = (FlxG.width / 2) - (test.width / 2);
		test.y = (FlxG.height / 2) - (test.height / 2);
		add(test);
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
