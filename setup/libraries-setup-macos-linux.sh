#!/bin/sh
# SETUP FOR MAC AND LINUX SYSTEMS
# REMINDER THAT YOU NEED HAXE INSTALLED PRIOR TO USING THIS
# https://haxe.org/download/4.3.6
cd ..
echo Making the main haxelib and setup folder in same time...
mkdir ~/haxelib && haxelib setup ~/haxelib
echo Installing dependencies...
echo This might take a few moments depending on your internet speed!
haxelib install lime 8.2.2
haxelib install openfl 9.4.1
haxelib install flixel 6.0.0
haxelib install flixel-addons 3.3.2
haxelib install flixel-tools 1.5.1
haxelib install hxdiscord_rpc 1.3.0
haxelib git install https://github.com/TheZoroForce240/FlxSoundFilters.git
echo Library downloads complete!
echo Running setup commands...
haxelib run lime setup
haxelib run lime setup flixel
haxelib run flixel-tools setup
echo Libraries setup complete!
