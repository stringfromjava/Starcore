package objects.entity;

import haxe.Exception;
import backend.util.GeneralUtil;
import flixel.FlxSprite;

/**
 * Component for creating the body parts of a complex entity.
 */
class EntityBodyPart extends FlxSprite {
    
    /**
     * The ID of `this` entity body part. Note that IDs for entities may only 
     * contain the following:
     * - Lowercase letters (no uppercase)
     * - Underscores
     */
    public var id:String;
    public var scaleX:Float;
    public var scaleY:Float;

    public function new(id:String, ox:Float, oy:Float, width:Float, height:Float, angle:Float, scaleX:Float, scaleY:Float, alpha:Float) {
        super();
        if (GeneralUtil.isValidName(id)) {
            this.id = id;
        } else {
            throw new Exception('"$id" is not a valid name for an entity!');
        }
        this.width = width;
        this.height = height;
        this.angle = angle;
        this.scaleX = scaleX;
        this.scaleY = scaleY;
        this.alpha = alpha;
    }
}
