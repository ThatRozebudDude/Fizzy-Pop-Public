package;

import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.addons.text.FlxTypeText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;

class VictoryScreen extends MusicBeatState
{
	public static var misses:Int = 0;

	var canExit:Bool;
	var string:String = '';
	var skipText:FlxText;

	override public function create()
	{
		super.create();
		FlxG.sound.cache(Paths.sound("shit"));
		var bg = new FlxBackdrop(Paths.image("victoryScreen/piss"), 1, 1, true, true);
		bg.velocity.x = 8;
		bg.velocity.y = 8;
		bg.antialiasing = true;
		add(bg);

		var shit = new FlxSprite(0.0);
		if (misses == 0)
		{
			shit.loadGraphic(Paths.image("victoryScreen/GOOD"));
			string = "You popped open a soda from the vending machine. It was the most delicate pop you'd ever tasted. Beautiful.";
		}
		else if (misses != 0 && misses <= 25)
		{
			shit.loadGraphic(Paths.image("victoryScreen/NORMAL"));
			string = 'You popped open a soda from the vending machine. It was a perfectly fine pop.';
		}
		else
		{
			shit.loadGraphic(Paths.image("victoryScreen/BAD"));
			string = 'You popped open a soda from the vending machine. It tasted like dogshit. Do better.';
		}
		shit.setGraphicSize(Std.int(shit.width * 0.3));
		shit.updateHitbox();
		shit.screenCenter();
		shit.antialiasing = true;
		shit.alpha = 0;
		add(shit);

		skipText = new FlxText(5, 695, 640, "Press ENTER to go back to the menu.\n", 40);
		skipText.scrollFactor.set(0, 0);
		skipText.setFormat('Pixel Arial 11 Bold', 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		skipText.borderSize = 2;
		skipText.borderQuality = 1;
		add(skipText);
		skipText.alpha = 0;

		var text = new FlxTypeText(shit.x, shit.y + 50, Std.int(shit.width), string, 24);
		text.font = 'Pixel Arial 11 Bold';
		text.screenCenter(Y);
		text.y += 200;
		text.sounds = [FlxG.sound.load(Paths.sound("pixelText"), 0.6)];
		text.color = FlxColor.WHITE;
	
		text.finishSounds = true;
		add(text);

		FlxTween.tween(shit, {alpha: 1}, 1, {
			startDelay: 2,
			ease: FlxEase.smoothStepIn,
			onComplete: function(twn:FlxTween)
			{
				FlxG.sound.play(Paths.sound("shit"));
				text.start(0.04, true);
				text.completeCallback = function()
					{
						canExit = true;
						FlxTween.tween(skipText, {alpha: 1}, 1, {ease: FlxEase.smoothStepOut});
					}
			}
		});
	}

	override public function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ENTER && canExit)
			FlxG.switchState(new MainMenuState());
	}
}
