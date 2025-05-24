package states.editors;

import states.menus.DebugMenuState;
import backend.Controls;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxState;

class EntityCreationEditorState extends FlxState {
    
    override function create() {
        super.create();

        FlxG.camera.bgColor = FlxColor.fromRGB(210, 210, 210);
    }

    override function update(elapsed:Float) {
        super.update(elapsed);

        if (Controls.getBinds().UI_BACK_JUST_PRESSED) {
            FlxG.switchState(() -> new DebugMenuState());
        }
    }
}
