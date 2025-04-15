package objects.ui.options;

import backend.data.ClientPrefs;
import backend.data.Constants;
import flixel.text.FlxText;

class OptionNumberScroller extends Option {

    private var _displayText:FlxText;

    private var decreaseArrow:ClickableSprite;
    private var increaseArrow:ClickableSprite;

    private var _isValidNumOption:Bool;
    
    public function new(x:Float, y:Float, decimalPlaces:Int, name:String, option:String, description:String = '[No Description Set]') {
        var clientPreference:Any = ClientPrefs.getClientPreference(option);
        this._isValidNumOption = Std.isOfType(clientPreference, Float);

        super(name, option, description);

        this._displayText = new FlxText();
        this._displayText.text = (_isValidNumOption) ? name : 'OPTION "${option}" IS NOT A VALID NUMBER';
        this._displayText.size = Constants.OPTION_DISPLAY_TEXT_SIZE;
        this._displayText.updateHitbox();
        this._displayText.setPosition(x, y);
    }

    public function onSelected():Void {}
}
