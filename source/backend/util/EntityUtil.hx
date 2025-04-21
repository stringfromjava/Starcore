package backend.util;

import objects.entity.Entity;

/**
 * Utility class for handling and modifying entities in
 * the world of Starcore.
 */
final class EntityUtil {

    /**
     * Get an entity by its ID.
     * 
     * @param id      The ID of the entity to get.
     * @return        The entity with the given ID, or null if not found.
     */
    public static function getEntityById(id:String):Entity {
        for (entity in CacheUtil.registeredEntities) {
            if (entity.id == id) {
                return entity;
            }
        }
        return null;
    }

    private function new() {}
}
