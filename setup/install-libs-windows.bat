@echo off
REM Batch script to install all Haxe libraries from hmm.json
REM Make sure you have Haxe and Haxelib installed and in your PATH

REM Install haxelib dependencies
haxelib install lime 8.2.2
haxelib install openfl 9.4.1
haxelib install flixel 6.1.0
haxelib install flixel-addons 3.3.2
haxelib install flixel-tools 1.5.1
haxelib install hxcpp-debug-server 1.2.4
haxelib install hxdiscord_rpc 1.3.0
haxelib install hxcpp 4.3.2
haxelib install hxp 1.3.0

REM Install git dependencies
haxelib git flxsoundfilters https://github.com/TheZoroForce240/FlxSoundFilters

echo All libraries installed!
pause
