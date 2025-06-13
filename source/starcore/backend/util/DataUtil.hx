package starcore.backend.util;

using StringTools;

/**
 * Utility class for manipulating data in `String`s,
 * `Array`s, `Dynamic` JSON data, or anything similar.
 */
final class DataUtil
{
	/**
	 * Removes a word from a string by its index.
	 * 
	 * ## Example
	 * ```
	 * var s:String = 'The second word will be removed!';
	 * trace(removeWordFromIndex(s, 1)); // Output: "The word will be removed!"
	 * ```
	 * 
	 * @param s         The string to remove the indexed word from.
	 * @param index     The index of the word to remove.
	 * @param delimiter How the words should be separated. A space (`' '`) is the default value.
	 * @param trim      Should the returned string trim its whitespace?
	 * @return          The new string (without the removed word).
	 */
	public static function removeWordFromIndex(s:String, index:Int, delimiter:String = ' ', trim:Bool = true):String
	{
		// Remove the word by the said index
		var toReturn:String = '';
		var sentence:Array<String> = s.trim().split(delimiter);
		// Convert it back to a regular string, but
		// without the removed word
		for (i in 0...sentence.length)
		{
			if (i != index)
			{
				toReturn += '${sentence[i]} ';
			}
		}
		
		if (trim)
		{
			return toReturn.trim();
		}
		else
		{
			return toReturn;
		}
	}

	/**
	 * Get a dynamic value from a `Dynamic` object. Note that this is meant 
	 * for JSON specific objects.
	 * 
	 * @param object       The JSON `Dynamic` object to obtain the field from.
	 * @param field        The field to get.
	 * @param defaultValue The value that is returned if the field does not exist.
	 * @return             The value found from the said field. If it isn't found, then the
	 *                     `defaultValue` parameter is returned instead.
	 */
	public static inline function getDynamicField(object:Dynamic, field:String, defaultValue:Dynamic):Any
	{
		return (Reflect.hasField(object, field)) ? Reflect.field(object, field) : defaultValue;
	}
}
