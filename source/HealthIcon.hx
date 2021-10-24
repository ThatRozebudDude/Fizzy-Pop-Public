package;

import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxSprite;

class HealthIcon extends FlxSprite
{
	public var sprTracker:FlxSprite;
	public var id:Int;

	public var defualtIconScale:Float = 1;
	public var iconScale:Float = 1;
	public var iconSize:Float;

	private var tween:FlxTween;

	private static final pixelIcons:Array<String> = ["bf-pixel", "senpai", "senpai-angry", "spirit"];

	public function new(char:String = 'face', isPlayer:Bool = false, ?_id:Int = -1)
	{
		super();
		loadGraphic(Paths.image('iconGrid'), true, 150, 150);
			
		animation.add('bf', [0, 1, 2], 0, false, isPlayer);
		animation.add('gf', [3, 4, 5], 0, false, isPlayer);
		animation.add('gf-cola', [3, 4, 5], 0, false, isPlayer);
		animation.add('emmi', [6, 7, 8], 0, false, isPlayer);
		animation.add('emmi-big', [6, 7, 8], 0, false, isPlayer);

		iconSize = width;

		id = _id;
		
		antialiasing = !pixelIcons.contains(char);
		animation.play(char);
		scrollFactor.set();

		tween = FlxTween.tween(this, {}, 0);
	}

	override function update(elapsed:Float)
	{


		super.update(elapsed);
		setGraphicSize(Std.int(iconSize * iconScale));
		updateHitbox();

		if (sprTracker != null){
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
			if(id == FreeplayState.curSelected){
				animation.curAnim.curFrame = 2;
			}
			else{
				animation.curAnim.curFrame = 0;
			}
		}
	}

	public function tweenToDefaultScale(_time:Float, _ease:Null<flixel.tweens.EaseFunction>){

		tween.cancel();
		tween = FlxTween.tween(this, {iconScale: this.defualtIconScale}, _time, {ease: _ease});

	}

}
