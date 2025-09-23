# How to Compile Starcore's Source Code

This guide will provide you every step needed to compile and run Starcore.  
__**Please read and follow each step carefully in order for the game to compile and run successfully.**__

## Global Setup (Every Platform)

These are the necessary steps required to compile on the game on __***every***__ platform. If you're on either Windows, macOS, or Linux, then read the applicable sub section in section `Extra Steps (for Running and Configuring the Game on Other Platforms)` below.

1. Download the [Haxe programming language](https://haxe.org/download/version/4.3.6).
    - When you download the necessary installer, just use the default options and configurations.

2. Download the [Git version control software made by GitHub](https://www.git-scm.com).
    - Similar to when you installed Haxe, just simply use the default configurations when going through the installer.

3. Open your operating system's terminal (or Command Prompt, if you're a Windows user).

4. Run `cd path/of/your/clone/here`. This is where the game's code will be stored, with `path/of/your/clone/here` being the file location.

> [!TIP]
> If you're on Windows, it's recommended for your clone's code to be placed in your Documents folder (or, if you have GitHub Desktop installed, in `Documents/GitHub`).

5. Run `git clone https://github.com/stringfromjava/Starcore.git` to install the game's code. **Note that this might take a while depending on your internet speed**.

6. When it is done installing, run `cd Starcore` to set the path to be the game's source code.

> [!IMPORTANT]
> When you need to run a command for the game, make sure your terminal's current directory is set to be the game's code (that's what the `cd` command is for). This also applies for when you are compiling the game with the `lime` command, which we will install in a little bit.

7. Run `haxelib --global install hmm` and then `haxelib --global run hmm setup` to install **Haxe Module Manager** (this is the library that will automatically install all of the game's dependencies).

8. Run `hmm install` to start installing all of the game's dependencies. **This will take a bit, so be patient**.

> [!TIP]
> If the libraries do not install correctly, then you can run the applicable file in the [setup](setup/) folder based to your operating system.

9. Run `haxelib run lime setup` to setup the lime command.
    - This will allow you to compile and run the game on many common platforms, such as every major desktop platform (Windows, macOS, Linux, etc.), both popular mobile systems (Android and iOS), and more.

10. Run `lime test html5 --connect 6000` to compile and run the game on the web.
    - You can find the compiled code in the `export/test` folder.

> [!TIP]
> You can replace `html5` with other platforms to compile it accordingly.

> [!TIP]
> If you run it on HTML5 and get a connection disallowed error, then run `lime test html5` (without `--connect 6000` at the end of it).

> [!IMPORTANT]
> If ever, for some reason, the shaders make the screen become black, it is advised you clear your computer's `Temp/` directory. If the issue persists, then please take a look at the [contributing](CONTRIBUTING.md) file for info on how to report a bug.

## Extra Steps (for Running and Configuring the Game on Other Platforms)

### Windows

1. Navigate to the [setup](setup/) folder and run the `msvs-setup.bat` file to install Visual Studio.
    - This will install everything needed to compile the game to become a Windows application. **This can take a while, so please be patient.**

2. When it is done installing, you can then run `lime test windows --connect 6000` to compile the game for Windows.

### macOS

You can learn how to compile the game for macOS [here](https://lime.openfl.org/docs/advanced-setup/macos/).

### Linux

You can learn how to compile the game for Linux [here](https://lime.openfl.org/docs/advanced-setup/linux/).
