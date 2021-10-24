package;

import flixel.system.FlxSound;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import openfl.display.BitmapData;
import openfl.media.Sound;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	static inline final GF_DEFAULT = 'gf default';

	var box:FlxSprite;
	var skipText:FlxText;
	var curCharacter:String = '';

	var curAnim:String = '';
	var prevChar:String = '';

	var effectQue:Array<String> = [""];
	var effectParamQue:Array<String> = [""];

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???/
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;
	// Cutscene shit, HAS TO LOAD ON EVERY STAGE IDIOT
	var cutsceneImage:FlxSprite;
	var sound:FlxSound;

	public var finishThing:Void->Void;

	var portraitBF:Portrait;
	var portraitGF:Portrait;
	var portraitEMMY:Portrait;
	var portraitEMMY2:Portrait;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;

	// var handSelect:FlxSprite;
	var bgFade:FlxSprite;
	var blackBG:FlxSprite;

	var canAdvance = false;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		new FlxTimer().start(0.5, function(tmr:FlxTimer)
		{
			canAdvance = true;
		});

		switch (PlayState.SONG.song.toLowerCase())
		{
			case 'senpai':
				//FlxG.sound.playMusic(Paths.music('Lunchbox'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
			case 'thorns':
				//FlxG.sound.playMusic(Paths.music('LunchboxScary'), 0);
				FlxG.sound.music.fadeIn(1, 0, 0.8);
		}

		blackBG = new FlxSprite(-256, -256).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		add(blackBG);

		bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
		bgFade.scrollFactor.set();
		bgFade.alpha = 0;
		add(bgFade);

		cutsceneImage = new FlxSprite(0, 0);
		cutsceneImage.visible = false;
		add(cutsceneImage);

		// if (PlayState.SONG.song.toLowerCase() == 'tutorial')
		// bgFade.visible = false;

		FlxTween.tween(bgFade, {alpha: 0.7}, 1, {ease: FlxEase.circOut});

		box = new FlxSprite(-20, 45);
		// REPOSITIONING, NEW ANIMATIONS AND MUSIC SHIT IDIOTS
		var hasDialog = false;
		switch (PlayState.SONG.song.toLowerCase())
		{
			default:
				hasDialog = true;
				box.frames = FlxAtlasFrames.fromSparrow('assets/images/speech_bubble_talking.png', 'assets/images/speech_bubble_talking.xml');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByPrefix('normal', 'speech bubble normal', 24, true);
				box.y += 345;
				box.x += 60;
				box.flipX = true;
			case 'senpai':
				hasDialog = true;
				// box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-pixel');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				// FlxG.sound.play(Paths.sound('ANGRY_TEXT_BOX'));

				// box.frames = Paths.getSparrowAtlas('weeb/pixelUI/dialogueBox-senpaiMad');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			
		}

		this.dialogueList = dialogueList;

		if (!hasDialog)
			return;

		portraitBF = new Portrait(170, 100, "bf");
		add(portraitBF);

		portraitGF = new Portrait(170, 100, "gf");
		add(portraitGF);
		portraitEMMY = new Portrait(170, 50, "emmy");
		add(portraitEMMY);
		portraitEMMY2 = new Portrait(170, 50, "emmy2");
		add(portraitEMMY2);

		box.animation.play('normalOpen');
		box.setGraphicSize(Std.int(box.width * 0.9));
		box.updateHitbox();
		add(box);

		box.screenCenter(X);

		// handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image('hand_textbox', 'shared'));
		// add(handSelect);

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", 32);
		dropText.font = 'Pixel Arial 11 Bold';
		dropText.color = 0xFFD89494;
		add(dropText);
		skipText = new FlxText(5, 695, 640, "Press SPACE to skip the dialogue.\n", 40);
		skipText.scrollFactor.set(0, 0);
		skipText.setFormat('Pixel Arial 11 Bold', 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.borderSize = 2;
		skipText.borderQuality = 1;
		add(skipText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", 32);
		swagDialogue.font = 'Pixel Arial 11 Bold';
		swagDialogue.color = 0xFF3F2021;
		swagDialogue.finishSounds = true;
		swagDialogue.sounds = [FlxG.sound.load(Paths.sound("pixelText"), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (PlayState.SONG.song.toLowerCase() == 'roses')
			portraitLeft.visible = false;
		if (PlayState.SONG.song.toLowerCase() == 'thorns')
		{
			portraitLeft.color = FlxColor.BLACK;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}
	
		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (FlxG.keys.justPressed.SPACE && !isEnding)
		{
			isEnding = true;
			endDialogue();
		}

		if (FlxG.keys.justPressed.ANY && dialogueStarted == true && canAdvance && !isEnding)
		{
			remove(dialogue);
			canAdvance = false;

			new FlxTimer().start(0.15, function(tmr:FlxTimer)
			{
				canAdvance = true;
			});

			FlxG.sound.play('assets/sounds/clickText.ogg', 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;
					endDialogue();
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function endDialogue()
	{
		if (PlayState.SONG.song.toLowerCase() == 'senpai' || PlayState.SONG.song.toLowerCase() == 'thorns')
			FlxG.sound.music.fadeOut(2.2, 0);

		hideAll();
		if (this.sound != null)
			this.sound.stop();
		FlxTween.tween(box, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(bgFade, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(cutsceneImage, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(swagDialogue, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(blackBG, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(dropText, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxTween.tween(skipText, {alpha: 0}, 1.2, {ease: FlxEase.circOut});
		FlxG.sound.music.fadeOut(1.2, 0);

		new FlxTimer().start(1.2, function(tmr:FlxTimer)
		{
			finishThing();
			kill();
			FlxG.sound.music.stop();
		});
	}

	function startDialogue():Void
	{
		var setDialogue = false;
		var skipDialogue = false;
		cleanDialog();
		hideAll();

		box.visible = true;
		box.flipX = true;
		swagDialogue.visible = true;
		dropText.visible = true;

		switch (curCharacter)
		{
			case "bf":
				portraitBF.playFrame(curAnim);
			
			case "gf":
				portraitGF.playFrame(curAnim);
				
			case 'emmy':
				portraitEMMY.playFrame(curAnim);
			case 'emmy2':
				portraitEMMY2.playFrame(curAnim);
			case "effect":
				switch (curAnim)
				{
					case "hidden":
						swagDialogue.visible = false;
						dropText.visible = false;
						box.visible = false;
						setDialogue = true;
						swagDialogue.resetText("");
					default:
						effectQue.push(curAnim);
						effectParamQue.push(dialogueList[0]);
						skipDialogue = true;
				}
			case "bg":
				skipDialogue = true;
				switch (curAnim)
				{
					case "hide":
						cutsceneImage.visible = false;
					default:
						cutsceneImage.visible = true;
						cutsceneImage.loadGraphic(BitmapData.fromFile(Paths.image("bg/" + curAnim)));
				}
			case "sound":
				skipDialogue = true;
				if (this.sound != null)
					this.sound.stop();
				sound = new FlxSound().loadEmbedded(Sound.fromFile(Paths.sound(curAnim)));
				sound.play();
			case "music":
				skipDialogue = true;
				switch (curAnim)
				{
					case "stop":
						FlxG.sound.music.stop();
					case "fadeIn":
						FlxG.sound.music.fadeIn(1.5, 0, Std.parseFloat(dialogueList[0]));
					case "fadeOut":
						FlxG.sound.music.fadeOut(1.5, 0);
					default:
						FlxG.sound.playMusic(Sound.fromFile(Paths.music(curAnim)), Std.parseFloat(dialogueList[0]));
				}

			default:
				trace("default dialogue event");
				portraitBF.playFrame();
		}

		prevChar = curCharacter;

		if (!skipDialogue)
		{
			if (!setDialogue)
			{
				swagDialogue.resetText(dialogueList[0]);
			}

			swagDialogue.start(0.04, true);
			runEffectsQue();
		}
		else
		{
			dialogueList.remove(dialogueList[0]);
			startDialogue();
		}
	}

	function cleanDialog():Void
	{
		while (dialogueList[0] == "")
		{
			dialogueList.remove(dialogueList[0]);
		}

		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		curAnim = splitName[2];

		dialogueList[0] = dialogueList[0].substr(splitName[1].length + splitName[2].length + 3).trim();
	}

	function runEffectsQue()
	{
		for (i in 0...effectQue.length)
		{
			switch (effectQue[i])
			{
				case "fadeOut":
					effectFadeOut(Std.parseFloat(effectParamQue[i]));
				case "fadeIn":
					effectFadeIn(Std.parseFloat(effectParamQue[i]));
				case "exitStageLeft":
					effectExitStageLeft(Std.parseFloat(effectParamQue[i]));
				case "exitStageRight":
					effectExitStageRight(Std.parseFloat(effectParamQue[i]));
				case "enterStageLeft":
					effectEnterStageLeft(Std.parseFloat(effectParamQue[i]));
				case "enterStageRight":
					effectEnterStageRight(Std.parseFloat(effectParamQue[i]));
				case "rightSide":
					effectFlipRight();
				case "flip":
					effectFlipDirection();
				case "toLeft":
					effectToLeft();
				case "toRight":
					effectToRight();
				case "black":
					black();
				case "resetColor":
					resetColor();
				// case "shake":
				// effectShake(Std.parseFloat(effectParamQue[i]));
				default:
			}
		}

		effectQue = [""];
		effectParamQue = [""];
	}

	

	function portraitArray()
	{
		// Why? i don't know, i was bored and hey it's easier to work with
		var portraitArray = [
			portraitBF, portraitGF, portraitEMMY, portraitEMMY2
		];
		return portraitArray;
	}

	function black()
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].black();
		}
	}

	function resetColor()
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].resetColor();
		}
	}

	function hideAll():Void
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].hide();
		}
	}

	function effectFadeOut(?time:Float = 1):Void
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectFadeOut(time);
		}
	}

	function effectFadeIn(?time:Float = 1):Void
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectFadeIn(time);
		}
	}

	function effectExitStageLeft(?time:Float = 1):Void
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectExitStageLeft(time);
		}
	}

	function effectExitStageRight(?time:Float = 1):Void
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectExitStageRight(time);
		}
	}

	function effectFlipRight()
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectFlipRight();
		}
		box.flipX = false;
	}

	function effectFlipDirection()
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectFlipDirection();
		}
	}

	function effectEnterStageLeft(?time:Float = 1)
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectEnterStageLeft(time);
		}
	}

	function effectEnterStageRight(?time:Float = 1)
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectEnterStageRight(time);
		}
	}

	function effectToRight(?time:Float = 1)
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectToRight(time);
		}

		box.flipX = false;
	}

	function effectToLeft(?time:Float = 1)
	{
		for (i in 0...portraitArray().length)
		{
			portraitArray()[i].effectToLeft(time);
		}
	}
}