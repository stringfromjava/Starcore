package objects.ui;

import backend.Controls;
import backend.data.ClientPrefs;
import backend.util.AssetUtil;
import backend.util.CacheUtil;
import backend.util.GeneralUtil;
import backend.util.PathUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

/**
 * Object used to create dialogue boxes during the game.
 */
class DialogueBox extends FlxTypedGroup<FlxSprite> {

    /**
     * The data that `this` dialogue box has.
     * This includes things like responses, what the speaker says,
     * what each response responds to, etc.
     */
    public var speechData(get, never):Array<Dynamic>;
    private var _speechData:Array<Dynamic>;

    /**
     * The ID of the speaker associated with the dialogue box.
     */
    public var speakerId(get, never):String;
    private var _speakerId:String;

  /**
   * Callback function that gets called when `this` dialogue box is
   * finished and fully completed by the user.
   */
  public var onDialogueComplete:Void->Void;

    private var _speaker:FlxSprite;
    private var _speakerData:Dynamic;
    private var _speakerEmotions:Array<Dynamic>;
    private var _currentSpeakerEmotion:String = '';
    private var _isDoneSpeaking:Bool = false;

    private var _dialogueText:FlxText;
    private var _dialogueBoxBase:FlxSprite;

    private var _currentDialogueIdx:Int = 0;
    private var _currentBubbleData:Dynamic;
    private var _oldBubbleData:Dynamic;
    private var _foundStartingBubble:Bool = false;

    private var _canEnterPrompt:Bool = false;

    private var _response1:ClickableText;
    private var _response2:ClickableText;

    private var _lastResponse:String;
    private var _lastResponseIndex:Int;

    private var _hoveredResponse:Int = 1;
    private var _hoverArrow:FlxSprite;

    private var _speakLoopAnimationTimer:FlxTimer = new FlxTimer();
    private var _onFinishSpeakingAnimationTimer:FlxTimer = new FlxTimer();
    private var _userAcceptBindPressTimer:FlxTimer = new FlxTimer();

    /**
     * Constructs a new dialogue instance, which is responsible for displaying
     * dialogue text and managing interactions within the dialogue system.
     * 
     * It initializes the dialogue box with the specified speech data and associates
     * it with a particular speaker. The `speechDataName` parameter is used to load the relevant
     * dialogue content, while the `speakerId` parameter identifies the character or entity
     * delivering the dialogue. These parameters allow the dialogue box to dynamically adapt
     * to different scenarios and speakers in the game.
     * 
     * For your `xml` data, each emotion (animation) should look like this format
     * (notice how each sub texture is formatted as the character's ID, the emotion, and then the frame):
     * 
     * ```xml
     * <SubTexture name="speaker_normal_0" ... />
     * <SubTexture name="speaker_confident_0" ... />
     * <SubTexture name="speaker_confident_1" ... />
     * <SubTexture name="speaker_confident_2" ... />
     * <SubTexture name="speaker_upset_0" ... />
     * <SubTexture name="speaker_upset_1" ... />
     * ```
     * 
     * @param speechDataName A string representing the name or key of the speech data resource
     *                       to be loaded. This is typically used to fetch pre-defined dialogue
     *                       content from a file.
     * @param speakerId      An identifier representing the speaker associated with 
     *                       this dialogue. This is used to obtain data, such as their emotions
     *                       (animations that can play), their name, etc.
     */
    public function new(speechDataName:String, speakerId:String) {
        super(6);

        CacheUtil.isDialogueFinished = false;

        this._speakerId = speakerId;
    this._speechData = AssetUtil.getJsonData(PathUtil.ofJson('dialogue/speeches/$speechDataName'), []);
    this._speakerData = AssetUtil.getJsonData(PathUtil.ofJson('dialogue/characters/$speakerId'), {});
        this._speakerEmotions = this._speakerData.emotions;

        this._speaker = new FlxSprite();
        this._speaker.frames = FlxAtlasFrames.fromSparrow(PathUtil.ofSpriteSheet('dialogue/${this._speakerId}')[0], PathUtil.ofSpriteSheet('dialogue/${this._speakerId}')[1]);

        this._dialogueBoxBase = new FlxSprite();
        this._dialogueBoxBase.makeGraphic(FlxG.width - 110, 220, FlxColor.BLACK);
        this._dialogueBoxBase.alpha = 1;    
        this._dialogueBoxBase.screenCenter(FlxAxes.X);
        this._dialogueBoxBase.y = (FlxG.height - _dialogueBoxBase.height) - 50;

        this._speaker.x = this._dialogueBoxBase.x;
        this._speaker.y = (this._dialogueBoxBase.y - this._speaker.height) + 120;

        this._dialogueText = new FlxText();
        this._dialogueText.text = this._speechData[this._currentDialogueIdx].text;
        this._dialogueText.size = 32;
        this._dialogueText.color = FlxColor.WHITE;
        this._dialogueText.updateHitbox();
        this._dialogueText.setPosition(this._dialogueBoxBase.x + 8, this._dialogueBoxBase.y + 8);

        this._response1 = new ClickableText();
        this._response1.size = 32;
        this._response1.color = FlxColor.WHITE;
        this._response1.updateHitbox();
        this._response1.onClick = () -> {
            _changeDialogue();
            if (this._currentBubbleData == this._oldBubbleData) {
                this.fadeOutAndDestroy();
            }
        };
        this._response1.onHover = () -> _setHoveredResponse(1);

        this._response2 = new ClickableText();
        this._response2.size = 32;
        this._response2.color = FlxColor.WHITE;
        this._response2.updateHitbox();
        this._response2.onClick = () -> {
            _changeDialogue();
            if (this._currentBubbleData == this._oldBubbleData) {
                this.fadeOutAndDestroy();
            }
        };
        this._response2.onHover = () -> _setHoveredResponse(2);

        this._hoverArrow = new FlxSprite();
        this._hoverArrow.loadGraphic(PathUtil.ofImage('arrow'));
        this._hoverArrow.scale.set(0.2, 0.2);
        this._hoverArrow.updateHitbox();

        this.add(this._speaker);
        this.add(this._dialogueBoxBase);
        this.add(this._dialogueText);
        this.add(this._response1);
        this.add(this._response2);
        this.add(this._hoverArrow);

        // Find the first speech bubble that has nothing contained
        // in the "responsefrom" array
        for (bubble in this._speechData) {
            if (bubble.responsefrom.length == 0) {
                this._foundStartingBubble = true;
                this._currentBubbleData = bubble;
                this._currentSpeakerEmotion = this._currentBubbleData.emotion;
                _changeDialogue(true);
                break;
            }
        }

        // Set the arrow to be on the first response
        this.changeHoverArrowLocation(this._hoveredResponse, false);

        // Add each animation, with the data from the speaker's character .json
        // file, with the .xml file from the images/spritesheets folder
        for (emtn in this._speakerEmotions) {
            var frames:Array<Int> = [];
            for (i in 0...emtn.frames) frames.push(i);
            this._speaker.animation.addByIndices(emtn.id, '${this._speakerId}_${emtn.id}_', frames, '', 15, false);
        }
    }

    // ------------------------------
    //      GETTERS AND SETTERS
    // ------------------------------

    @:noCompletion
    public inline function get_speechData():Dynamic {
        return this._speechData;
    }

    @:noCompletion
    public inline function get_speakerId():String {
        return this._speakerId;
    }

    public inline function getLastResponse():String {
        return _lastResponse;
    }

    public inline function getLastResponseIndex():Int {
        return _lastResponseIndex;
    }

    // -----------------------------
    //            METHODS
    // -----------------------------

    override function update(elapsed:Float) {
        super.update(elapsed);

        // Check if the left/right bind was pressed
        // to switch responses
        if (Controls.binds.UI_LEFT_JUST_PRESSED) {
            this._switchHoveredResponse(1);
        } else if (Controls.binds.UI_RIGHT_JUST_PRESSED) {
            this._switchHoveredResponse(2);
        }

        // If the user presses the accept bind, then load the next response
    if (Controls.binds.UI_SELECT_JUST_PRESSED && this._canEnterPrompt) {
            _changeDialogue();
            if (this._currentBubbleData == this._oldBubbleData) {
                this.fadeOutAndDestroy();
            }
        }
    }

    /**
     * Changes what response the funni little arrow is hovering over.
     * 
     * @param location       Which response the arrow should hover over.
     * @param playHoverSound Should the arrow play a sound when it changes options?
     */
    public function changeHoverArrowLocation(location:Int, playHoverSound:Bool = true):Void {
        if (playHoverSound && _response2.text != '') {
            FlxG.sound.play(PathUtil.ofSound('blip'));
        }
        switch (location) {
            case (1):
                _hoverArrow.x = (_response1.x + (_response1.width / 2) - (_hoverArrow.width / 2));
                _hoverArrow.y = (_response1.y + _response1.height) + 1;
            case (2):
                if (_response2.text == '') {
                    return;
                }
                _hoverArrow.x = (_response2.x + (_response2.width / 2) - (_hoverArrow.width / 2));
                _hoverArrow.y = (_response2.y + _response2.height) + 1;
        }
    }

    /**
     * Sets a response with new data. This is used usually when a new bubble is being generated.
     * 
     * @param r    The response to change.
     * @param text The text to set it too.
     */
    public function setResponse(r:Int, text:String):Void {
        switch (r) {
            case (1):
                this._response1.text = text;
                this._response1.updateHitbox();
                this._response1.x = (this._dialogueBoxBase.x + 30);
                this._response1.y = (this._dialogueBoxBase.y + this._dialogueBoxBase.height) - this._response1.height - 30;
                this._response1.updateHoverBounds();
            case (2):
                this._response2.text = text;
                this._response2.updateHitbox();
                this._response2.x = (this._response1.x + this._response1.width) + 20;
                this._response2.y = (this._dialogueBoxBase.y + this._dialogueBoxBase.height) - this._response2.height - 30;
                this._response2.updateHoverBounds();      
        }
    }

    /**
     * Change both responses at the same time, using the whole speech bubble data to use.
     * 
     * @param bubbleData The speech bubble data to obtain the responses from. 
     */
    public function setResponses(bubbleData:Dynamic):Void {
        var isR1Null:Bool = (bubbleData.responses[0] == null);
        var isR2Null:Bool = (bubbleData.responses[1] == null);
        setResponse(1, (!isR1Null) ? bubbleData.responses[0] : 'Press ${ClientPrefs.get_controlsKeyboard().get('ui_select').toString()} to continue...');
        setResponse(2, (!isR2Null) ? bubbleData.responses[1] : '');
    }

    /**
     * Add a cool fadeout and then destroy `this` dialogue box.
     */
    public function fadeOutAndDestroy(duration:Float = 1):Void {
        _canEnterPrompt = false;
        _speakLoopAnimationTimer.cancel();
        _userAcceptBindPressTimer.cancel();
        _onFinishSpeakingAnimationTimer.cancel();
        GeneralUtil.tweenSpriteGroup(this, { alpha: 0 }, duration, { type: FlxTweenType.ONESHOT });
        new FlxTimer().start(duration, (_) -> { 
            CacheUtil.isDialogueFinished = true;
            onDialogueComplete(); 
            this.destroy(); 
        });
    }

    private function _setHoveredResponse(r:Int) {
        _hoveredResponse = r;
        switch (r) {
            case (1):
                changeHoverArrowLocation(1);
            case (2):
                changeHoverArrowLocation(2);
        }
    }

    private function _switchHoveredResponse(r:Int) {
        switch (r) {
            case (1):
                _hoveredResponse--;
                if (_hoveredResponse < 1) _hoveredResponse = 2;
                changeHoverArrowLocation(_hoveredResponse);
            case (2):
                _hoveredResponse++;
                if (_hoveredResponse > 2) _hoveredResponse = 1;
                changeHoverArrowLocation(_hoveredResponse);
        }
    }

    private function _changeDialogue(isFirstBubble:Bool = false):Void {
        // Reset hover states for both responses
        _response1.isHovered = false;
        _response2.isHovered = false;

        // Set the last response text and index
        _lastResponse = this._currentBubbleData.responses[this._hoveredResponse - 1];
        _lastResponseIndex = _hoveredResponse;

        // Store the current bubble data as the old bubble data
        _oldBubbleData = this._currentBubbleData;

        // Clear the text of both responses and hide the hover arrow
        _response1.text = '';
        _response2.text = '';
        _hoverArrow.visible = false; 

        // Disable the ability to enter a prompt temporarily
        _canEnterPrompt = false;

        // If this is not the first bubble, find the next bubble based on the current response
        if (!isFirstBubble) {
            for (bubble in this._speechData) {
                // Extract the "responsefrom" array from the bubble data because HTML5 whines about it :/
                var rf:Array<String> = bubble.responsefrom;
                // Check if the current response matches any elements in the "responsefrom" array
                if (rf.contains(_lastResponse)) {
                    _currentBubbleData = bubble;  // Set the next bubble as the current bubble
                    break;
                }
            }
        }

        // Reset the hovered response to the first response
        _hoveredResponse = 1;

        // Total duration of the speaking animation
        var speakingLength:Float = 0;
        // Tracks the current length of the displayed text
        var currentSpliceLength:Int = 0;  
        // The full text of the current bubble
        var speakText:String = _currentBubbleData.text; 

        // The text that is actually displayed to the user
        var realText:String = '';
    // Create a dummy text that is used for calculating width for the text
        var dummyText:FlxText = new FlxText();
        dummyText.size = _dialogueText.size;
        dummyText.visible = false;
        dummyText.updateHitbox();

        // Loop through each word and insert new line escape characters when needed
        for (word in speakText.split(' ')) {
            dummyText.text += '$word ';
            dummyText.updateHitbox();
            if (!(dummyText.width > _dialogueBoxBase.width - 8)) {
                realText += '$word ';
            } else {
                realText += '\n$word ';
                dummyText.text = '';
                dummyText.updateHitbox();
            }
        }

        // If the dialogue animations option is ON, then
        // animate the text to make it look :sparkles: fancy :sparkles:
        if (ClientPrefs.options.dialogueAnimations) {
            // Calculate the total speaking duration based on the text length
            for (_ in 0...speakText.length) {
                speakingLength += 0.03;
            }

            // Start a timer to display the text character by character.
            _speakLoopAnimationTimer.start(
                0.03,  // Interval for each character to appear
                (_) -> {
                    // Increment the displayed text length
                    currentSpliceLength++;
                    // Update the displayed text
                    _dialogueText.text = realText.substring(0, currentSpliceLength);
                    // Play a sound effect for the current character
                    FlxG.sound.play(PathUtil.ofSound('dialogue/${this._speakerId}-${this._currentSpeakerEmotion}'), false, false);
                },
                speakText.length  // Number of iterations equal to the text length
            );

            // Start a timer to allow skipping the animation by pressing a key or clicking
            _userAcceptBindPressTimer.start(
                0.0001,  // Very short interval to check for input
                (_) -> {
                    // If the user presses the select key or clicks anywhere on the screen, skip the animation
                    if (Controls.binds.UI_SELECT_JUST_PRESSED || FlxG.mouse.justPressed) {
                        // Display the full text immediately
            _dialogueText.text = realText;

                        // Stop all timers
                        _speakLoopAnimationTimer.cancel();
                        _userAcceptBindPressTimer.cancel();
                        _onFinishSpeakingAnimationTimer.cancel();
                        
                        // Set the responses for the next bubble
                        _resetResponses(); 
                    }
                },
                0  // Infinite repetitions until manually canceled
            );

            // Start a timer to reset responses after the speaking animation finishes.
            this._onFinishSpeakingAnimationTimer.start(
                speakingLength, // Duration of the speaking animation
                (_) -> {
                    // Reset the responses for the next bubble
                    _resetResponses();
                }
            );
        } else {
            // If animations are disabled, display the full text immediately
            _dialogueText.text = realText;
            // Play a sound effect for the dialogue
            FlxG.sound.play(PathUtil.ofSound('dialogue/${this._speakerId}-${this._currentSpeakerEmotion}'), false, false);
            // Set the responses for the current bubble
            _resetResponses();
        }
    }

    private function _resetResponses() {
        setResponses(_currentBubbleData);
        changeHoverArrowLocation(1, false);
        _hoverArrow.visible = true;
        _currentSpeakerEmotion = _currentBubbleData.emotion;
        _speaker.animation.play(_currentSpeakerEmotion);
        new FlxTimer().start(0.3, (_) -> { _canEnterPrompt = true; });
    }
}
