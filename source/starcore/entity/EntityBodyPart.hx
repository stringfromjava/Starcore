package starcore.entity;

import flixel.FlxSprite;
import haxe.Exception;
import starcore.backend.util.EntityUtil;

/**
 * Component for creating the body parts of a complex entity.
 */
class EntityBodyPart extends FlxSprite
{
  /**
   * The ID of `this` entity body part. Note that IDs for entities may only 
   * contain the following:
   * - Lowercase letters (no uppercase)
   * - Underscores
   */
  public var id:String;

  public function new(id:String, ox:Float, oy:Float, width:Float, height:Float, angle:Float, alpha:Float)
  {
    super();
    if (EntityUtil.isValidName(id))
    {
      this.id = id;
    }
    else
    {
      throw new Exception('"$id" is not a valid name for an entity!');
    }
    this.width = width;
    this.height = height;
    this.angle = angle;
    this.alpha = alpha;
  }
}
