package;

import flixel.util.FlxTimer;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';

	public var holdTimer:Float = 0;

	public var canAutoAnim:Bool = true;
	public var floating:Bool = false;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;

		var tex:FlxAtlasFrames;
		antialiasing = true;

		switch (curCharacter)
		{
			case 'gf':
				// GIRLFRIEND CODE
				frames = Paths.getSparrowAtlas("GF_assets");
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				addOffset('cheer');
				addOffset('sad', -2, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);

				addOffset("singUP", 0, 4);
				addOffset("singRIGHT", 0, -20);
				addOffset("singLEFT", 0, -19);
				addOffset("singDOWN", 0, -20);
				addOffset('hairBlow', 45, -8);
				addOffset('hairFall', 0, -9);

				addOffset('scared', -2, -17);

				playAnim('danceRight');

			case 'gf-cola':
				frames = Paths.getSparrowAtlas('soda/GF_cola');
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
	
				addOffset('sad', -2, -21);
				addOffset('danceLeft', 0, -9);
				addOffset('danceRight', 0, -9);
	
				playAnim('danceRight');

			case 'bf':
				frames = Paths.getSparrowAtlas("BOYFRIEND");
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);
				animation.addByPrefix('attack', 'boyfriend attack', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				playAnim('idle');

				flipX = true;

			case 'emmi':
				frames = Paths.getSparrowAtlas('soda/fizzy');
				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singUP', 'Sing Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24, false);
				animation.addByPrefix('singDOWN', 'Sing Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sing Left', 24, false);

				addOffset('idle');
				addOffset("singUP", 29, 7);
				addOffset("singRIGHT", -13, -1);
				addOffset("singLEFT", 93, 1);
				addOffset("singDOWN", -24, -9);

				playAnim('idle');

			case 'emmi-big':
				frames = Paths.getSparrowAtlas('soda/bunga');
				animation.addByPrefix('idle', '1emidle', 24, false);
				animation.addByPrefix('singUP', '2up', 24, false);
				animation.addByPrefix('singRIGHT', '5left', 24, false);
				animation.addByPrefix('singDOWN', '3down', 24, false);
				animation.addByPrefix('singLEFT', '4right', 24, false);
	
				addOffset('idle');
				addOffset("singUP", 28, 2);
				addOffset("singRIGHT", -58, 6);
				addOffset("singLEFT", -21, 7);
				addOffset("singDOWN", 117, -9);

				setGraphicSize(Std.int(width * 0.8));
				updateHitbox();

				playAnim('idle');
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}

		animation.finishCallback = animationEnd;

	}

	override function update(elapsed:Float)
	{
		if (!isPlayer)
		{
			if (animation.curAnim.name.startsWith('sing'))
			{
				holdTimer += elapsed;
			}

			var dadVar:Float = 4;

			if (curCharacter == 'dad')
				dadVar = 6.1;
			if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
			{
				idleEnd();
				holdTimer = 0;
			}
		}

		switch (curCharacter)
		{
			case 'gf' | "gf-cola":
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(?ignoreDebug:Bool = false)
	{
		if (!debugMode || ignoreDebug)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-cola':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight', true);
						else
							playAnim('danceLeft', true);
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight', true);
					else
						playAnim('danceLeft', true);
				default:
					if(holdTimer == 0)
						playAnim('idle', true);
			}
		}
	}

	public function idleEnd(?ignoreDebug:Bool = false)
	{
		if (!debugMode || ignoreDebug)
		{
			switch (curCharacter)
			{
				case 'gf' | 'gf-cola' | "spooky":
					playAnim('danceRight', true, false, animation.getByName('danceRight').numFrames - 1);
				default:
					playAnim('idle', true, false, animation.getByName('idle').numFrames - 1);
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(animation.curAnim.name);
		if (animOffsets.exists(animation.curAnim.name))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	function animationEnd(name:String){

		switch(curCharacter){
			case "emmi":
				switch(name){
					case "idle":
						playAnim(name, false, false, 8);
				}
			
			case "mom-car":
				switch(name){
					case "idle":
						playAnim(name, false, false, 8);
					case "singUP":
						playAnim(name, false, false, 4);
					case "singDOWN":
						playAnim(name, false, false, 4);
					case "singLEFT":
						playAnim(name, false, false, 2);
					case "singRIGHT":
						playAnim(name, false, false, 2);
				}

			case "bf-car":
				switch(name){
					case "idle":
						playAnim(name, false, false, 8);
					case "singUP":
						playAnim(name, false, false, 3);
					case "singDOWN":
						playAnim(name, false, false, 2);
					case "singLEFT":
						playAnim(name, false, false, 4);
					case "singRIGHT":
						playAnim(name, false, false, 2);
				}

			case "monster-christmas" | "monster":
				switch(name){
					case "idle":
						playAnim(name, false, false, 10);
					case "singUP":
						playAnim(name, false, false, 8);
					case "singDOWN":
						playAnim(name, false, false, 7);
					case "singLEFT":
						playAnim(name, false, false, 5);
					case "singRIGHT":
						playAnim(name, false, false, 6);
				}

		}

	}

	public function floatStart(_distance:Int, _time:Float)
	{
		floating = true;
		floatUp(_distance, _time);
	}
	
	public function floatStop()
	{
		floating = false;
	}
	
	function floatUp(_distance:Int, _time:Float)
	{
		FlxTween.tween(this, {y: y - _distance, alpha: 1}, _time, {ease: FlxEase.sineOut, onComplete: function(tween){
			floatDown(_distance, _time);
		}});
	}
	
	function floatDown(_distance:Int, _time:Float)
	{
		FlxTween.tween(this, {y: y + _distance, alpha: 1}, _time, {ease: FlxEase.sineInOut, onComplete: function(tween){
			if(floating)
				floatUp(_distance, _time);
		}});
	}
}
