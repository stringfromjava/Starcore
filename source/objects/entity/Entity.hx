package objects.entity;

import backend.util.FlixelUtil;
import flixel.FlxObject;
import flixel.group.FlxGroup.FlxTypedGroup;
import haxe.Exception;

/**
 * Core class for creating entities in Starcore.
 */
abstract class Entity extends FlxTypedGroup<FlxObject> {

    /**
     * The ID of `this` entity. Note that IDs for entities may only 
     * contain the following:
     * - Lowercase letters (no uppercase)
     * - Underscores
     */
    public var id(get, never):String;
    private var _id:String;

    public function new(id:String) {
        super();
		if (FlixelUtil.isValidName(id)) {
            this._id = id;
        } else {
            throw new Exception('"$id" is not a valid name for an entity!');
        }
    }

    // ------------------------------
    //      GETTERS AND SETTERS
    // ------------------------------

    @:noCompletion
    public function get_id():String {
        return this._id;
    }
}
