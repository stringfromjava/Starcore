# How to Contribute

Since Starcore isn't that big of a game yet, things are somewhat simple.
All we ask is that you follow the basic rules and have common sense.

When you write code, heres some simple things we ask of you:

## Issues

If you wish to fix a bug, make an enhancement, or even wish to
simply make a recommendation, then no worries! You can make an [issue](https://github.com/stringfromjava/Starcore/issues)
or create a sub-issue and help someone with an issue that needs to be worked on!

> [!IMPORTANT]
> Make sure to set the base branch to `develop` on your pull request or otherwise ***it will NOT be merged and accepted!!***

## Comments & Formatting

Comments are very valuable because they allow you and other
programmers to easily understand what is happening in your code.

However, sometimes they can be a hindrance as well.

If your comments have typos, aren't clear or concise, or just
hard to understand in general, then they won't be any
use. Even too many comments are unnecessary, since your code should be
self documented and easily readable.

### Example of GOOD Comments (With Good Formatting)

```haxe
/**
 * Gets the last key that was pressed on the current frame.
 * 
 * @return The last key that was pressed. If no keys were pressed, then
 * `FlxKey.NONE` is returned instead.
 */
public static function getLastKeyPressed():FlxKey
{
  for (key in 8...303) // Loop through all keys in FlxKey
  {
    try
    {
      if (FlxG.keys.anyJustPressed([key]))
      {
        return key;
      }
    }
    catch (e:Exception)
    {
      // Skip and move on if it is not a valid key
    }
  }
  return FlxKey.NONE;
}
```

### Example of BAD Comments (With Bad Formatting)

```haxe

/**
 * gets the last key or whatever that was pressed
 * return the last thing pressed lolz
 */
public 
static 
function getLastpressed():FlxKey
{
  // loop thouhg all keys (8-303)
    for (key in 8...303) // loop through all keys
  {
        // try to check if its pressed :p
      try{
            // check if its pressed
          if (FlxG.keys.anyJustPressed([key]))
        {
              // return the pressed key
                  return key;
            }
        }
    // catch the exception
    catch (e:Exception) {
          // just skip with non valid key xd
    }
  }
// return nnoe if no kyes are pressed
  return FlxKey.NONE;
}
```

> [!TIP]
> You can format a file on VS Code with `SHIFT` + `ALT` + `F` to match the code style standards, although just know that it won't fix typos or correct your grammar, that's all on you!

## Things You CANNOT Do

Excluding *collaborators*, there are some files that contributors simply cannot change or delete.

1. You are not allowed to change these files:
    - Any files in the [.github folder](.github/).
    - Any files in the [setup folder](setup/).
    - Any files in the [unused folder](unused/).
    - `.gitattributes`
    - `.gitignore`
    - `.prettier.js`
    - `checkstyle.json`
    - `COMPILING.md`
    - `CONTRIBUTING.md`
    - `hmm.json`
    - `hxformat.json`
    - `LICENSE.md`
    - `project.hxp`
    - `README.md`
