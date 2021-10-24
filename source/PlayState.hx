package;

#if sys
import sys.FileSystem;
#end

import config.*;
import title.*;

import lime.utils.Assets;
import flixel.math.FlxRect;
import openfl.system.System;
import openfl.ui.KeyLocation;
import flixel.input.keyboard.FlxKey;
import openfl.ui.Keyboard;
import openfl.events.KeyboardEvent;
//import polymod.fs.SysFileSystem;
import Section.SwagSection;
import Song.SwagSong;
//import WiggleEffect.WiggleEffectType;
//import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
//import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
//import flixel.FlxState;
import flixel.FlxSubState;
//import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
//import flixel.addons.effects.FlxTrailArea;
//import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
//import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
//import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
//import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
//import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
//import haxe.Json;
//import lime.utils.Assets;
//import openfl.display.BlendMode;
//import openfl.display.StageQuality;
//import openfl.filters.ShaderFilter;

using StringTools;

class PlayState extends MusicBeatState
{

	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	
	public static var returnLocation:String = "main";
	public static var returnSong:Int = 0;
	
	private var canHit:Bool = false;
	private var noMissCount:Int = 0;

	public static final mansionSongs = ["popped", "fizzed", "glamour"]; //List isn't really used since stage is default, but whatever.

	private var camFocus:String = "";
	private var camTween:FlxTween;
	private var camZoomTween:FlxTween;
	private var uiZoomTween:FlxTween;
	private var camFollow:FlxObject;
	private var autoCam:Bool = true;
	private var autoZoom:Bool = true;
	private var autoUi:Bool = true;

	private var bopSpeed:Int = 1;

	private var sectionHasOppNotes:Bool = false;
	private var sectionHasBFNotes:Bool = false;
	private var sectionHaveNotes:Array<Array<Bool>> = [];

	private var vocals:FlxSound;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	//Wacky input stuff=========================

	private var skipListener:Bool = false;

	private var upTime:Int = 0;
	private var downTime:Int = 0;
	private var leftTime:Int = 0;
	private var rightTime:Int = 0;

	private var upPress:Bool = false;
	private var downPress:Bool = false;
	private var leftPress:Bool = false;
	private var rightPress:Bool = false;
	
	private var upRelease:Bool = false;
	private var downRelease:Bool = false;
	private var leftRelease:Bool = false;
	private var rightRelease:Bool = false;

	private var upHold:Bool = false;
	private var downHold:Bool = false;
	private var leftHold:Bool = false;
	private var rightHold:Bool = false;

	//End of wacky input stuff===================

	private var invuln:Bool = false;
	private var invulnCount:Int = 0;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var enemyStrums:FlxTypedGroup<FlxSprite>;

	private var camZooming:Bool = true;
	private var curSong:String = "";

	private var health:Float = 1;
	private var combo:Int = 0;
	private var misses:Int = 0;
	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camDialogue:FlxCamera;
	private var camGame:FlxCamera;
	private var camOverlay:FlxCamera;

	private var comboUI:ComboPopup;
	public static final minCombo:Int = 10;

	var usesDialogue = false;

	var dialogue:Array<String> = [':bf:strange code', ':dad:>:]'];

	/*var bfPos:Array<Array<Float>> = [
									[975.5, 862],
									[975.5, 862],
									[975.5, 862],
									[1235.5, 642],
									[1175.5, 866],
									[1295.5, 866],
									[1189, 1108],
									[1189, 1108]
									];

	var dadPos:Array<Array<Float>> = [
									 [314.5, 867],
									 [346, 849],
									 [326.5, 875],
									 [339.5, 914],
									 [42, 882],
									 [342, 861],
									 [625, 1446],
									 [334, 968]
									 ];*/

	var halloweenBG:FlxSprite;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	//var wiggleShit:WiggleEffect = new WiggleEffect();

	var talking:Bool = true;
	var songScore:Int = 0;
	var scoreTxt:FlxText;

	public static var campaignScore:Int = 0;

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	var dadBeats:Array<Int> = [0, 2];
	var bfBeats:Array<Int> = [1, 3];

	public static var sectionStart:Bool =  false;
	public static var sectionStartPoint:Int =  0;
	public static var sectionStartTime:Float =  0;

	private var meta:SongMetaTags;
	
	override public function create()
	{

		instance = this;
		FlxG.mouse.visible = false;
		PlayerSettings.gameControls();

		FlxG.sound.cache(Paths.music(SONG.song + "_Inst"));
		FlxG.sound.cache(Paths.music(SONG.song + "_Voices"));
		
		if(Config.noFpsCap)
			openfl.Lib.current.stage.frameRate = 999;
		else
			openfl.Lib.current.stage.frameRate = 144;

		camTween = FlxTween.tween(this, {}, 0);
		camZoomTween = FlxTween.tween(this, {}, 0);
		uiZoomTween = FlxTween.tween(this, {}, 0);

		for(i in 0 ... SONG.notes.length){

			var array = [false, false];

			array[0] = sectionContainsBfNotes(i);
			array[1] = sectionContainsOppNotes(i);

			sectionHaveNotes.push(array);

		}
		
		canHit = !(Config.ghostTapType > 0);
		noMissCount = 0;
		invulnCount = 0;
	
		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camDialogue = new FlxCamera();
		camDialogue.bgColor.alpha = 0;
		camOverlay = new FlxCamera();
		camOverlay.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camOverlay);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camDialogue);

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.changeBPM(SONG.bpm);

		if(Assets.exists("assets/data/" + SONG.song.toLowerCase() + "/dialogue.txt")){
			dialogue = CoolUtil.coolTextFile("assets/data/" + SONG.song.toLowerCase() + "/dialogue.txt");
			usesDialogue = true;
		}

		var stageCheck:String = 'mansion';
		if (SONG.stage == null) {
			
			SONG.stage = stageCheck;

		}
		else {stageCheck = SONG.stage;}

		curStage = 'mansion';
		defaultCamZoom = 0.7;
		var bg:FlxSprite = new FlxSprite(-200,-20).loadGraphic(Paths.image("soda/FIZZ_BG"));
		bg.setGraphicSize(Std.int(bg.width * 1.7));
		bg.updateHitbox();
		bg.antialiasing = true;
		add(bg);

		switch(SONG.song.toLowerCase()){
			case "tutorial":
				autoZoom = false;
				dadBeats = [0, 1, 2, 3];
			case "bopeebo":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "fresh":
				camZooming = false;
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "spookeez":
				dadBeats = [0, 1, 2, 3];
			case "south":
				dadBeats = [0, 1, 2, 3];
			case "monster":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "cocoa":
				dadBeats = [0, 1, 2, 3];
				bfBeats = [0, 1, 2, 3];
			case "thorns":
				dadBeats = [0, 1, 2, 3];
		}

		var gfVersion:String = 'gf';

		if (SONG.gf == null) {
			switch(storyWeek)
			{
				case 4: gfVersion = 'gf-car';
				case 5: gfVersion = 'gf-christmas';
				case 6: gfVersion = 'gf-pixel';
			}

			SONG.gf = gfVersion;

		} else {gfVersion = SONG.gf;}

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		dad = new Character(100, 100, SONG.player2);

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case "gf" | "gf-cola":
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
				}

			case "emmi":
				dad.y += 200;
				camPos.x += 450;
				camPos.y += 200;
			case "emmi-big":
				dad.y += 105;
				camPos.x += 450;
				camPos.y += 50;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		switch(curStage){

			case "mansion":
				boyfriend.y += 200;
				boyfriend.x += 250;
				gf.y += 200;
				gf.x += 100;

		}

		add(gf);
		
		if (curStage == 'limo')
			add(limo);
		
		add(dad);
		if (dad.curCharacter == 'emmi')
			dad.floatStart(50, 1);

		add(boyfriend);

		comboUI = new ComboPopup(boyfriend.x - 250, boyfriend.y - 75,	[Paths.image("ratings"), 403, 163, true], 
																		[Paths.image("numbers"), 100, 120, true], 
																		[Paths.image("comboBreak"), 348, 211, true]);

		if(Config.comboType == 1){

			comboUI.cameras = [camHUD];
			comboUI.setPosition(0, 0);
			comboUI.scrollFactor.set(0, 0);
			comboUI.setScales([comboUI.ratingScale * 0.8, comboUI.numberScale, comboUI.breakScale * 0.8]);
			comboUI.accelScale = 0.2;
			comboUI.velocityScale = 0.2;

			if(!Config.downscroll){
				comboUI.ratingPosition = [700, 510];
				comboUI.numberPosition = [320, 480];
				comboUI.breakPosition = [690, 465];
			}
			else{
				comboUI.ratingPosition = [700, 80];
				comboUI.numberPosition = [320, 100];
				comboUI.breakPosition = [690, 85];
			}

		}

		if(Config.comboType < 2){
			add(comboUI);
		}

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		if(Config.downscroll){
			strumLine = new FlxSprite(0, 570).makeGraphic(FlxG.width, 10);
		}
		else {
			strumLine = new FlxSprite(0, 30).makeGraphic(FlxG.width, 10);
		}
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		enemyStrums = new FlxTypedGroup<FlxSprite>();

		// startCountdown();

		generateSong(SONG.song);

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON);
		
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		if(Assets.exists(Paths.text(SONG.song.toLowerCase() + "/meta"))){
			meta = new SongMetaTags(0, 144, SONG.song.toLowerCase());
			meta.cameras = [camHUD];
			add(meta);
		}

		healthBarBG = new FlxSprite(0, Config.downscroll ? FlxG.height * 0.1 : FlxG.height * 0.875).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();
		add(healthBarBG);

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);
		// healthBar
		
		scoreTxt = new FlxText(healthBarBG.x - 105, (FlxG.height * 0.9) + 36, 800, "", 22);
		scoreTxt.setFormat(Paths.font("vcr"), 22, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		
		add(healthBar);
		add(iconP2);
		add(iconP1);
		add(scoreTxt);

		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		doof.cameras = [camDialogue];

		healthBar.visible = false;
		healthBarBG.visible = false;
		iconP1.visible = false;
		iconP2.visible = false;
		scoreTxt.visible = false;

		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode)
		{
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				default:
					if(usesDialogue){
						startCutscene(doof);
					}
					else{
						startCountdown();
						}
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		//FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
		//FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, keyUp);

		var bgDim = new FlxSprite(1280 / -2, 720 / -2).makeGraphic(1280*2, 720*2, FlxColor.BLACK);
		bgDim.cameras = [camOverlay];
		bgDim.alpha = Config.bgDim/10;
		add(bgDim);

		super.create();
	}

	function updateAccuracy()
	{

		totalPlayed += 1;
		accuracy = totalNotesHit / totalPlayed * 100;
		if (accuracy >= 100){
			accuracy = 100;
		}
		
	}

	function startCutscene(dialogueBox:DialogueBox){

		inCutscene = true;
		camHUD.visible = false;
		add(dialogueBox);

	}

	var startTimer:FlxTimer;

	function startCountdown():Void
	{
		inCutscene = false;
		camHUD.visible = true;
		healthBar.visible = true;
		healthBarBG.visible = true;
		iconP1.visible = true;
		iconP2.visible = true;
		scoreTxt.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);
			introAssets.set('schoolEvil', [
				'weeb/pixelUI/ready-pixel',
				'weeb/pixelUI/set-pixel',
				'weeb/pixelUI/date-pixel'
			]);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}


		startTimer = new FlxTimer().start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if(dadBeats.contains((swagCounter % 4)))
				dad.dance();

			gf.dance();

			if(bfBeats.contains((swagCounter % 4)))
				boyfriend.dance();

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
					if(meta != null){
						meta.start();
					}
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.antialiasing = !curStage.startsWith('school');

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom * 0.8));
					else
						ready.setGraphicSize(Std.int(ready.width * 0.5));

					ready.updateHitbox();

					ready.screenCenter();
					ready.y -= 120;
					ready.cameras = [camHUD];
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					set.antialiasing = !curStage.startsWith('school');

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom * 0.8));
					else
						set.setGraphicSize(Std.int(set.width * 0.5));

					set.updateHitbox();

					set.screenCenter();
					set.y -= 120;
					set.cameras = [camHUD];
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();
					go.antialiasing = !curStage.startsWith('school');

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom * 0.8));
					else
						go.setGraphicSize(Std.int(go.width * 0.8));

					go.updateHitbox();

					go.screenCenter();
					go.y -= 120;
					go.cameras = [camHUD];
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.music(SONG.song + "_Inst"), 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		if(sectionStart){
			FlxG.sound.music.time = sectionStartTime;
			Conductor.songPosition = sectionStartTime;
			vocals.time = sectionStartTime;
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			if(!paused)
			resyncVocals();
		});

	}

	private function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
		{
			vocals = new FlxSound().loadEmbedded(Paths.music(curSong + "_Voices"));
		}
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		//for (section in noteData)
		for (section in noteData)
		{
			if(sectionStart && daBeats < sectionStartPoint){
				daBeats++;
				continue;
			}

			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, false, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.round(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, false, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats++;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(50, strumLine.y);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrowUP');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrowDOWN');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrowLEFT');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.y -= 10;
			babyArrow.alpha = 0;
			FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}
			else
			{
				enemyStrums.add(babyArrow);
				babyArrow.animation.finishCallback = function(name:String){
					if(name == "confirm"){
						babyArrow.animation.play('static', true);
						babyArrow.centerOffsets();
					}
				}
			}

			babyArrow.animation.play('static');
			babyArrow.x += 50;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{

		PlayerSettings.gameControls();

		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;
		}

		setBoyfriendInvuln(1/60);

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}


	override public function update(elapsed:Float)
	{

		/*New keyboard input stuff. Disables the listener when using controller because controller uses the other input set thing I did.
		
		if(skipListener) {keyCheck();}

		if(FlxG.gamepads.anyJustPressed(ANY) && !skipListener) {
			skipListener = true;
			trace("Using controller.");
		}
		
		if(FlxG.keys.justPressed.ANY && skipListener) {
			skipListener = false;
			trace("Using keyboard.");
		}

		//=============================================================*/

		keyCheck(); //Gonna stick with this for right now. I have the other stuff on standby in case this still is not working for people.

		if (FlxG.keys.justPressed.NINE)
		{
			if (iconP1.animation.curAnim.name == 'bf-old')
				iconP1.animation.play(SONG.player1);
			else
				iconP1.animation.play('bf-old');
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		switch(Config.accuracy){
			case "none":
				scoreTxt.text = "Score:" + songScore;
			default:
				scoreTxt.text = "Score:" + songScore + " | Misses:" + misses + " | Accuracy:" + truncateFloat(accuracy, 2) + "%";
		}

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			PlayerSettings.menuControls();

			openSubState(new PauseSubState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			PlayerSettings.menuControls();
			FlxG.switchState(new ChartingState());
			sectionStart = false;
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);
		}

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		//Heath Icons
		if (healthBar.percent < 20){
			iconP1.animation.curAnim.curFrame = 1;
			iconP2.animation.curAnim.curFrame = 2;
		}
		else if (healthBar.percent > 80){
			iconP1.animation.curAnim.curFrame = 2;
			iconP2.animation.curAnim.curFrame = 1;
		}
		else{
			iconP1.animation.curAnim.curFrame = 0;
			iconP2.animation.curAnim.curFrame = 0;
		}
			
		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		if (FlxG.keys.justPressed.EIGHT){

			PlayerSettings.menuControls();
			sectionStart = false;
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			if(FlxG.keys.pressed.SHIFT){
				FlxG.switchState(new AnimationDebug(SONG.player1));
			}
			else if(FlxG.keys.pressed.CONTROL){
				FlxG.switchState(new AnimationDebug(gf.curCharacter));
			}
			else{
				FlxG.switchState(new AnimationDebug(SONG.player2));
			}
		}
			

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			if (camFocus != "dad" && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusOpponent();
			}

			if (camFocus != "bf" && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && autoCam)
			{
				camFocusBF();
			}
		}

		FlxG.watch.addQuick("totalBeats: ", totalBeats);

		if (curSong == 'Fresh')
		{
			switch (totalBeats)
			{
				case 16:
					camZooming = true;
					bopSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 48:
					bopSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 80:
					bopSpeed = 2;
					dadBeats = [0, 2];
					bfBeats = [1, 3];
				case 112:
					bopSpeed = 1;
					dadBeats = [0, 1, 2, 3];
					bfBeats = [0, 1, 2, 3];
				case 163:
			}
		}

		// RESET = Quick Game Over Screen
		if (controls.RESET && !startingSong)
		{
			health = 0;
			//trace("RESET = True");
		}

		// CHEAT = brandon's a pussy
		if (controls.CHEAT)
		{
			health += 1;
			//trace("User is cheating!");
		}

		if (health <= 0)
		{
			//boyfriend.stunned = true;

			persistentUpdate = false;
			persistentDraw = false;
			paused = true;

			vocals.stop();
			FlxG.sound.music.stop();

			PlayerSettings.menuControls();
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y, camFollow.getScreenPosition().x, camFollow.getScreenPosition().y));
			sectionStart = false;

		}

		if (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1500)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				/*if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}*/

				if (!daNote.mustPress && daNote.wasGoodHit)
				{

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					//trace("DA ALT THO?: " + SONG.notes[Math.floor(curStep / 16)].altAnim);

					if(dad.canAutoAnim){
						switch (Math.abs(daNote.noteData))
						{
							case 2:
								dad.playAnim('singUP' + altAnim, true);
							case 3:
								dad.playAnim('singRIGHT' + altAnim, true);
							case 1:
								dad.playAnim('singDOWN' + altAnim, true);
							case 0:
								dad.playAnim('singLEFT' + altAnim, true);
						}
					}

					enemyStrums.forEach(function(spr:FlxSprite)
					{
						if (Math.abs(daNote.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
							if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
							{
								spr.centerOffsets();
								spr.offset.x -= 14;
								spr.offset.y -= 14;
							}
							else
								spr.centerOffsets();
						}
					});

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					if(!daNote.isSustainNote){
						daNote.destroy();
					}
				}

				if(Config.downscroll){
					daNote.y = (strumLine.y + (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));	

					if(daNote.isSustainNote){

						daNote.y -= daNote.height;
						daNote.y += 125;

						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
							swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
	
							daNote.clipRect = swagRect;
						}

					}
				}
				else {
					daNote.y = (strumLine.y - (Conductor.songPosition - daNote.strumTime) * (0.45 * FlxMath.roundDecimal(PlayState.SONG.speed, 2)));

					if(daNote.isSustainNote){

						if ((!daNote.mustPress || daNote.wasGoodHit || daNote.prevNote.wasGoodHit && !daNote.canBeHit)
							&& daNote.y + daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
						{
							// Clip to strumline
							var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
							swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+ Note.swagWidth / 2
								- daNote.y) / daNote.scale.y;
							swagRect.height -= swagRect.y;

							daNote.clipRect = swagRect;
						}

					}
				}


				//MOVE NOTE TRANSPARENCY CODE BECAUSE REASONS 
				if(daNote.tooLate){

					if (daNote.alpha > 0.3){

						noteMiss(daNote.noteData, 0.055, false, true);
						vocals.volume = 0;
						daNote.alpha = 0.3;
		
					}

				}

				if (Config.downscroll ? (daNote.y > strumLine.y + daNote.height + 50) : (daNote.y < strumLine.y - daNote.height - 50))
				{

					if (daNote.tooLate || daNote.wasGoodHit){
								
						daNote.active = false;
						daNote.visible = false;
			
						daNote.destroy();
		
					}
				}
			});
		}

		if (!inCutscene)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end

		
		leftPress = false;
		leftRelease = false;
		downPress = false;
		downRelease = false;
		upPress = false;
		upRelease = false;
		rightPress = false;
		rightRelease = false;

	}

	public function endSong():Void
	{
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}
		if (isStoryMode){
			VictoryScreen.misses += misses;
			trace(VictoryScreen.misses);
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music(TitleScreen.titleMusic), 0.75);

				PlayerSettings.menuControls();
				//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
				//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

				if (curSong == 'Glamour')
					FlxG.switchState(new VictoryScreen());
				else
					FlxG.switchState(new StoryMenuState());
				sectionStart = false;

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				//trace('LOADING NEXT SONG');
				//trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'));
				}

				if (SONG.song.toLowerCase() == 'senpai')
				{
					transIn = null;
					transOut = null;
					prevCamFollow = camFollow;
				}

				PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
				FlxG.sound.music.stop();

				FlxG.switchState(new PlayState());

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;
			}
		}
		else
		{
			PlayerSettings.menuControls();
			sectionStart = false;
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			//FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyUp);

			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);

		var score:Int = 350;

		var daRating:String = "sick";

		if (noteDiff > Conductor.safeZoneOffset * Conductor.shitZone)
			{
				daRating = 'shit';
				if(Config.accuracy == "complex") {
					totalNotesHit += 1 - Conductor.shitZone;
				}
				else {
					totalNotesHit += 1;
				}
				score = 50;
			}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.badZone)
			{
				daRating = 'bad';
				score = 100;
				if(Config.accuracy == "complex") {
					totalNotesHit += 1 - Conductor.badZone;
				}
				else {
					totalNotesHit += 1;
				}
			}
		else if (noteDiff > Conductor.safeZoneOffset * Conductor.goodZone)
			{
				daRating = 'good';
				if(Config.accuracy == "complex") {
					totalNotesHit += 1 - Conductor.goodZone;
				}
				else {
					totalNotesHit += 1;
				}
				score = 200;
			}
		if (daRating == 'sick')
			totalNotesHit += 1;
	
		//trace('hit ' + daRating);

		songScore += score;

		comboUI.ratingPopup(daRating);

		if(combo >= minCombo)
			comboUI.comboPopup(combo);

	}

	public function keyDown(evt:KeyboardEvent):Void{

		if(skipListener) {return;}

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
	
		var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];

		var data = -1;

		switch(evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		switch(data){

			case 0:
				if(leftHold) { return; }
				leftPress = true;
				leftHold = true;
			case 1:
				if(downHold) { return; }
				downPress = true;
				downHold = true;
			case 2:
				if(upHold) { return; }
				upPress = true;
				upHold = true;
			case 3:
				if(rightHold) { return; }
				rightPress = true;
				rightHold = true;

		}

	}

	public function keyUp(evt:KeyboardEvent):Void{

		if(skipListener) {return;}

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));
	
		var binds:Array<String> = [FlxG.save.data.leftBind,FlxG.save.data.downBind, FlxG.save.data.upBind, FlxG.save.data.rightBind];

		var data = -1;

		switch(evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		switch(data){

			case 0:
				leftRelease = true;
				leftHold = false;
			case 1:
				downRelease = true;
				downHold = false;
			case 2:
				upRelease = true;
				upHold = false;
			case 3:
				rightRelease = true;
				rightHold = false;

		}
		
	}

	private function keyCheck():Void{

		upTime = controls.UP ? upTime + 1 : 0;
		downTime = controls.DOWN ? downTime + 1 : 0;
		leftTime = controls.LEFT ? leftTime + 1 : 0;
		rightTime = controls.RIGHT ? rightTime + 1 : 0;

		upPress = upTime == 1;
		downPress = downTime == 1;
		leftPress = leftTime == 1;
		rightPress = rightTime == 1;

		upRelease = upHold && upTime == 0;
		downRelease = downHold && downTime == 0;
		leftRelease = leftHold && leftTime == 0;
		rightRelease = rightHold && rightTime == 0;

		upHold = upTime > 0;
		downHold = downTime > 0;
		leftHold = leftTime > 0;
		rightHold = rightTime > 0;

		/*THE FUNNY 4AM CODE!
		trace((leftHold?(leftPress?"^":"|"):(leftRelease?"^":" "))+(downHold?(downPress?"^":"|"):(downRelease?"^":" "))+(upHold?(upPress?"^":"|"):(upRelease?"^":" "))+(rightHold?(rightPress?"^":"|"):(rightRelease?"^":" ")));
		I should probably remove this from the code because it literally serves no purpose, but I'm gonna keep it in because I think it's funny.
		It just sorta prints 4 lines in the console that look like the arrows being pressed. Looks something like this:
		====
		^  | 
		| ^|
		| |^
		^ |
		====*/

	}

	private function keyShit():Void
	{

		var controlArray:Array<Bool> = [leftPress, downPress, upPress, rightPress];

		if ((upPress || rightPress || downPress || leftPress) && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
				{
					// the sorting probably doesn't need to be in here? who cares lol
					possibleNotes.push(daNote);
					possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

					ignoreList.push(daNote.noteData);

					if(Config.ghostTapType == 1)
						setCanMiss();
				}

			});

			var directionsAccounted = [false,false,false,false];

			if (possibleNotes.length > 0)
			{
				var daNote = possibleNotes[0];

				// Jump notes
				if (possibleNotes.length >= 2)
				{
					if (inRange(possibleNotes[0].strumTime, possibleNotes[1].strumTime, 4))
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData] && !directionsAccounted[coolNote.noteData])
							{
								goodNoteHit(coolNote);
								directionsAccounted[coolNote.noteData] = true;
							}
							else
							{
								var inIgnoreList:Bool = false;
								for (shit in 0...ignoreList.length)
								{
									if (controlArray[ignoreList[shit]])
										inIgnoreList = true;
								}
								if (!inIgnoreList){
									badNoteCheck();
								}
							}
						}
					}
					else if (possibleNotes[0].noteData == possibleNotes[1].noteData)
					{
						if (controlArray[daNote.noteData] && !directionsAccounted[daNote.noteData])
						{
							goodNoteHit(daNote);
							directionsAccounted[daNote.noteData] = true;
						}
					}
					else
					{
						for (coolNote in possibleNotes)
						{
							if (controlArray[coolNote.noteData] && !directionsAccounted[coolNote.noteData] && !coolNote.isSustainNote)
							{
								goodNoteHit(coolNote);
								directionsAccounted[coolNote.noteData] = true;
							}
						}
					}
				}
				else // regular notes?
				{
					if (controlArray[daNote.noteData] && !directionsAccounted[daNote.noteData])
					{
						goodNoteHit(daNote);
						directionsAccounted[daNote.noteData] = true;
					}
				}
				/* 
					if (controlArray[daNote.noteData])
						goodNoteHit(daNote);
				 */
				// trace(daNote.noteData);
				/* 
					switch (daNote.noteData)
					{
						case 2: // NOTES YOU JUST PRESSED
							if (upP || rightP || downP || leftP)
								noteCheck(upP, daNote);
						case 3:
							if (upP || rightP || downP || leftP)
								noteCheck(rightP, daNote);
						case 1:
							if (upP || rightP || downP || leftP)
								noteCheck(downP, daNote);
						case 0:
							if (upP || rightP || downP || leftP)
								noteCheck(leftP, daNote);
					}
				 */
				/*if (daNote.wasGoodHit && !daNote.isSustainNote)
				{
					daNote.destroy();
				}*/
			}
			else
			{
				badNoteCheck();
			}
		}
		
		notes.forEachAlive(function(daNote:Note)
		{
			if ((upHold || rightHold || downHold || leftHold) && generatedMusic){
				if (daNote.canBeHit && daNote.mustPress && daNote.isSustainNote)
				{

					boyfriend.holdTimer = 0;

					switch (daNote.noteData)
					{
						// NOTES YOU ARE HOLDING
						case 2:
							if (upHold)
								goodNoteHit(daNote);
						case 3:
							if (rightHold)
								goodNoteHit(daNote);
						case 1:
							if (downHold)
								goodNoteHit(daNote);
						case 0:
							if (leftHold)
								goodNoteHit(daNote);
					}
				}
			}

			//Guitar Hero Type Held Notes
			if(daNote.isSustainNote && daNote.mustPress){

				if(daNote.prevNote.tooLate && !daNote.prevNote.wasGoodHit){
					daNote.tooLate = true;
					daNote.destroy();
					updateAccuracy();
				}

				if(daNote.prevNote.wasGoodHit && !daNote.wasGoodHit){

					switch(daNote.noteData){
						case 0:
							if(leftRelease){
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.destroy();
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
						case 1:
							if(downRelease){
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.destroy();
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
						case 2:
							if(upRelease){
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.destroy();
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
						case 3:
							if(rightRelease){
								noteMissWrongPress(daNote.noteData, 0.0475, true);
								vocals.volume = 0;
								daNote.tooLate = true;
								daNote.destroy();
								boyfriend.holdTimer = 0;
								updateAccuracy();
							}
					}
				}
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !upHold && !downHold && !rightHold && !leftHold)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing'))
				boyfriend.idleEnd();
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			switch (spr.ID)
			{
				case 2:
					if (upPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!upHold)
						spr.animation.play('static');
				case 3:
					if (rightPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!rightHold)
						spr.animation.play('static');
				case 1:
					if (downPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!downHold)
						spr.animation.play('static');
				case 0:
					if (leftPress && spr.animation.curAnim.name != 'confirm')
						spr.animation.play('pressed');
					if (!leftHold)
						spr.animation.play('static');
			}

			switch(spr.animation.curAnim.name){

				case "confirm":

					//spr.alpha = 1;
					spr.centerOffsets();

					if(!curStage.startsWith('school')){
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}

				/*case "static":
					spr.alpha = 0.5; //Might mess around with strum transparency in the future or something.
					spr.centerOffsets();*/

				default:
					//spr.alpha = 1;
					spr.centerOffsets();

			}

		});
	}

	private function keyShitAuto():Void
	{

		var hitNotes:Array<Note> = [];

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.mustPress && daNote.strumTime < Conductor.songPosition + Conductor.safeZoneOffset * 0.125)
			{
				hitNotes.push(daNote);
			}
		});

		if (boyfriend.holdTimer > Conductor.stepCrochet * 4 * 0.001 && !upHold && !downHold && !rightHold && !leftHold)
		{
			if (boyfriend.animation.curAnim.name.startsWith('sing'))
				boyfriend.idleEnd();
		}

		for(x in hitNotes){

			boyfriend.holdTimer = 0;

			goodNoteHit(x);
			
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(x.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
					if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
					{
						spr.centerOffsets();
						spr.offset.x -= 14;
						spr.offset.y -= 14;
					}
					else
						spr.centerOffsets();
				}
			});

		}

		
	}

	function noteMiss(direction:Int = 1, ?healthLoss:Float = 0.04, ?playAudio:Bool = true, ?skipInvCheck:Bool = false):Void
	{
		if (!startingSong && (!invuln || skipInvCheck) )
		{
			health -= healthLoss * Config.healthDrainMultiplier;
			if (combo > minCombo)
			{
				gf.playAnim('sad');
				comboUI.breakPopup();
			}
			misses += 1;
			combo = 0;

			songScore -= 100;
			
			if(playAudio){
				FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));
			}

			setBoyfriendInvuln(5 / 60);

			if(boyfriend.canAutoAnim){
				switch (direction)
				{
					case 2:
						boyfriend.playAnim('singUPmiss', true);
					case 3:
						boyfriend.playAnim('singRIGHTmiss', true);
					case 1:
						boyfriend.playAnim('singDOWNmiss', true);
					case 0:
						boyfriend.playAnim('singLEFTmiss', true);
				}
			}

			updateAccuracy();
		}

		if(Main.flippymode) { System.exit(0); }

	}

	function noteMissWrongPress(direction:Int = 1, ?healthLoss:Float = 0.0475, dropCombo:Bool = false):Void
		{
			if (!startingSong && !invuln)
			{
				health -= healthLoss * Config.healthDrainMultiplier;

				if(dropCombo){
					if (combo > minCombo){
						gf.playAnim('sad');
						comboUI.breakPopup();
					}	
					combo = 0;
				}
	
				songScore -= 25;
				
				FlxG.sound.play(Paths.sound('missnote' + FlxG.random.int(1, 3)), FlxG.random.float(0.1, 0.2));
	
				setBoyfriendInvuln(4 / 60);
	
				if(boyfriend.canAutoAnim){
					switch (direction)
					{
						case 2:
							boyfriend.playAnim('singUPmiss', true);
						case 3:
							boyfriend.playAnim('singRIGHTmiss', true);
						case 1:
							boyfriend.playAnim('singDOWNmiss', true);
						case 0:
							boyfriend.playAnim('singLEFTmiss', true);
					}
				}
			}
		}

	function badNoteCheck()
	{
		if(Config.ghostTapType > 0 && !canHit){}
		else{
			if (leftPress)
				noteMissWrongPress(0);
			if (upPress)
				noteMissWrongPress(2);
			if (rightPress)
				noteMissWrongPress(3);
			if (downPress)
				noteMissWrongPress(1);
		}
	}

	function setBoyfriendInvuln(time:Float = 5 / 60){

		invulnCount++;
		var invulnCheck = invulnCount;

		invuln = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if(invulnCount == invulnCheck){

				invuln = false;

			}
			
		});

	}

	function setCanMiss(time:Float = 10 / 60){

		noMissCount++;
		var noMissCheck = noMissCount;

		canHit = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			if(noMissCheck == noMissCount){

				canHit = false;

			}
			
		});

	}

	/*function setBoyfriendStunned(time:Float = 5 / 60){

		boyfriend.stunned = true;

		new FlxTimer().start(time, function(tmr:FlxTimer)
		{
			boyfriend.stunned = false;
		});

	}*/

	function goodNoteHit(note:Note):Void
	{

		//Guitar Hero Styled Hold Notes
		if(note.isSustainNote && !note.prevNote.wasGoodHit){
			noteMiss(note.noteData, 0.05, true, true);
			note.prevNote.tooLate = true;
			note.prevNote.destroy();
			vocals.volume = 0;
		}

		else if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			if (note.noteData >= 0){
				health += 0.015 * Config.healthMultiplier;
			}
			else{
				health += 0.0015 * Config.healthMultiplier;
			}
				
			if(boyfriend.canAutoAnim){
				switch (note.noteData)
				{
					case 2:
						boyfriend.playAnim('singUP', true);
					case 3:
						boyfriend.playAnim('singRIGHT', true);
					case 1:
						boyfriend.playAnim('singDOWN', true);
					case 0:
						boyfriend.playAnim('singLEFT', true);
				}
			}

			if(!note.isSustainNote){
				setBoyfriendInvuln(2.5 / 60);
			}
			

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if(!note.isSustainNote){
				note.destroy();
			}
			
			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.sound('carPass' + FlxG.random.int(0, 1)), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		if (!trainSound.playing)
			trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.sound('thunder_' + FlxG.random.int(1, 2)));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		if (SONG.needsVoices)
		{
			if (vocals.time > Conductor.songPosition + 20 || vocals.time < Conductor.songPosition - 20)
			{
				resyncVocals();
			}
		}

		/*if (dad.curCharacter == 'spooky' && totalSteps % 4 == 2)
		{
			// dad.dance();
		}*/

		super.stepHit();
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		//wiggleShit.update(Conductor.crochet);
		super.beatHit();

		if(curBeat % 4 == 0){

			var sec = Math.floor(curBeat / 4);
			if(sec >= sectionHaveNotes.length) { sec = -1; }

			sectionHasBFNotes = sec >= 0 ? sectionHaveNotes[sec][0] : false;
			sectionHasOppNotes = sec >= 0 ? sectionHaveNotes[sec][1] : false;
			
		}

		if (generatedMusic)
		{
			notes.sort(FlxSort.byY, FlxSort.DESCENDING);
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			else
				Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			if (!sectionHasOppNotes)
				if(dadBeats.contains(curBeat % 4) && dad.canAutoAnim)
					dad.dance();
			
		}
		else{
			if(dadBeats.contains(curBeat % 4))
				dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);

		// HARDCODING FOR MILF ZOOMS!
		if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat <= 200 && camZooming && FlxG.camera.zoom < 1.35)
		{
			uiBop(0.015, 0.03);
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 168)
		{
			dadBeats = [0, 1, 2, 3];
			bfBeats = [0, 1, 2, 3];
		}

		if (curSong.toLowerCase() == 'milf' && curBeat == 200)
		{
			dadBeats = [0, 2];
			bfBeats = [1, 3];
		}

		if(curBeat % (4 * bopSpeed) == 0 && camZooming){
			uiBop();
		}

		if (curBeat % bopSpeed == 0){
			iconP1.iconScale = iconP1.defualtIconScale * 1.25;
			iconP2.iconScale = iconP2.defualtIconScale * 1.25;

			iconP1.tweenToDefaultScale(0.2, FlxEase.quintOut);
			iconP2.tweenToDefaultScale(0.2, FlxEase.quintOut);

			gf.dance();

		}

		if(bfBeats.contains(curBeat % 4) && boyfriend.canAutoAnim)
			boyfriend.dance();

		if (totalBeats % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);

		}

		switch (curStage)
		{
			case "school":
				bgGirls.dance();

			case "mall":
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case "limo":
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
				
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (totalBeats % 4 == 0)
				{
					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (totalBeats % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (curStage == "spooky" && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;

	function sectionContainsBfNotes(section:Int):Bool{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for(x in notes){
			if(mustHit) { if(x[1] < 4) { return true; } }
			else { if(x[1] > 3) { return true; } }
		}

		return false;
	}

	function sectionContainsOppNotes(section:Int):Bool{
		var notes = SONG.notes[section].sectionNotes;
		var mustHit = SONG.notes[section].mustHitSection;

		for(x in notes){
			if(mustHit) { if(x[1] > 3) { return true; } }
			else { if(x[1] < 4) { return true; } }
		}

		return false;
	}

	function camFocusOpponent(){

		var followX = dad.getMidpoint().x + 150;
		var followY = dad.getMidpoint().y - 100;
		// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

		switch (dad.curCharacter)
		{
			case "spooky":
				followY = dad.getMidpoint().y - 30;
			case "mom" | "mom-car":
				followY = dad.getMidpoint().y;
			case 'senpai':
				followY = dad.getMidpoint().y - 430;
				followX = dad.getMidpoint().x - 100;
			case 'senpai-angry':
				followY = dad.getMidpoint().y - 430;
				followX = dad.getMidpoint().x - 100;
			case 'spirit':
				followY = dad.getMidpoint().y;
			case 'emmi':
				followX = dad.getMidpoint().x + 400;
				followY = dad.getMidpoint().y + 50;
			case 'emmi-big':
				followX = dad.getMidpoint().x + 450;
				followY = dad.getMidpoint().y + 50;
		}

		/*if (dad.curCharacter == 'mom')
			vocals.volume = 1;*/

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1.3, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "dad");
	}

	function camFocusBF(){

		var followX = boyfriend.getMidpoint().x - 100;
		var followY = boyfriend.getMidpoint().y - 100;

		switch (curStage)
		{
			case 'spooky':
				followY = boyfriend.getMidpoint().y - 125;
			case 'limo':
				followX = boyfriend.getMidpoint().x - 300;
			case 'mall':
				followY = boyfriend.getMidpoint().y - 200;
			case 'school':
				followX = boyfriend.getMidpoint().x - 200;
				followY = boyfriend.getMidpoint().y - 225;
			case 'schoolEvil':
				followX = boyfriend.getMidpoint().x - 200;
				followY = boyfriend.getMidpoint().y - 225;
			case 'mansion':
				followY = boyfriend.getMidpoint().y - 200;
				followX = boyfriend.getMidpoint().x - 300;
		}

		if (SONG.song.toLowerCase() == 'tutorial')
		{
			camChangeZoom(1, (Conductor.stepCrochet * 4 / 1000), FlxEase.elasticInOut);
		}

		camMove(followX, followY, 1.9, FlxEase.quintOut, "bf");
	}

	function camMove(_x:Float, _y:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_focus:String = "", ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camTween.cancel();
		camTween = FlxTween.tween(camFollow, {x: _x, y: _y}, _time, {ease: _ease, onComplete: _onComplete});
		camFocus = _focus;

	}

	function camChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		camZoomTween.cancel();
		camZoomTween = FlxTween.tween(FlxG.camera, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});

	}

	function uiChangeZoom(_zoom:Float, _time:Float, _ease:Null<flixel.tweens.EaseFunction>, ?_onComplete:Null<TweenCallback> = null):Void{

		if(_onComplete == null){
			_onComplete = function(tween:FlxTween){};
		}

		uiZoomTween.cancel();
		uiZoomTween = FlxTween.tween(camHUD, {zoom: _zoom}, _time, {ease: _ease, onComplete: _onComplete});

	}

	function uiBop(?_camZoom:Float = 0.01, ?_uiZoom:Float = 0.02){

		if(autoZoom){
			camZoomTween.cancel();
			FlxG.camera.zoom = defaultCamZoom + _camZoom;
			camChangeZoom(defaultCamZoom, 0.6, FlxEase.quintOut);
		}

		if(autoUi){
			uiZoomTween.cancel();
			camHUD.zoom = 1 + _uiZoom;
			uiChangeZoom(1, 0.6, FlxEase.quintOut);
		}

	}

	function inRange(a:Float, b:Float, tolerance:Float){
		return (a <= b + tolerance && a >= b - tolerance);
	}

}
