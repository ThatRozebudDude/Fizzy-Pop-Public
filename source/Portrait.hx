package;

import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

using StringTools;

class Portrait extends FlxSprite
{

    private var refx:Float;
    private var refy:Float;

    private var resize = 0.35;

    public var characters:Array<String> = ["bf", "gf", "emmy", "emmy2"];

    var posTween:FlxTween;
    var alphaTween:FlxTween;
	
    public function new(_x:Float, _y:Float, _character:String){

        super(_x, _y);

        defineCharacter(_character);
        setGraphicSize(Std.int(width * resize));
        updateHitbox();
        scrollFactor.set();
        antialiasing = true;

        refx = x;
        refy = y + height;

        playFrame();
        posTween = FlxTween.tween(this, {x: x}, 0.1);
        alphaTween = FlxTween.tween(this, {alpha: alpha}, 0.1);
        hide();

    }

    function defineCharacter(_character){

        _character = characters.contains(_character) ? _character : "bf";
        trace(_character);
        frames = FlxAtlasFrames.fromSparrow('assets/images/portraits/$_character.png','assets/images/portraits/$_character.xml');

        switch(_character){

            case "noChar":
                addAnim("default", "noChar instance 1");
            case "bf":
                addAnim('confused','confused');
                addAnim('default','default');
                addAnim('shit','shit');
                addAnim('soul','soul');
                addAnim('thumbsup','thumbsup');
               

                animation.play("default");
                //resize = 0.5;
            case "gf":
                addAnim('default','GF1.png instance 1');
                addAnim('happy','GF5.png instance 1');
                addAnim('smile','GF3.png instance 1');
                addAnim('surprised','GF2.png instance 1');
                addAnim('scared','GF4.png instance 1');
                animation.play("default");
                resize = 0.30;
            case "emmy":
                addAnim("default", "default");
                addAnim("annoyed", "annoyed");
                addAnim("sad", "sad");
                addAnim("smile", "smile");
                animation.play("default");
                flipX = true;
            
               // resize = 0.13;
            case "emmy2":
                addAnim("H1", "Emmi2.png instance 1");
                addAnim("H2", "Emmi4.png instance 1");
                addAnim("H3", "Emmi5.png instance 1");
                addAnim("dark1", "Emmi1.png instance 1");
                addAnim("dark2", "Emmi3.png instance 1");
                animation.play("H1");
                flipX = true;
        }

     

    }
    
    function addAnim(anim:String, prefix:String){
        animation.addByPrefix(anim,prefix, 0, false);
    }    
    function addAnim2(anim:String, prefix:String,indices:Array<Int>){
        animation.addByIndices(anim,prefix,indices,"", 0, false);
    }    

    public function playFrame(?_frame:String = "default"){

        visible = true;

        animation.play(_frame);
        flipX = false;
        updateHitbox();

        x = refx;
        y = refy - height;

    }

    public function hide(){

        alphaTween.cancel();
        posTween.cancel();
        alpha = 1;
        visible = false;

    }

    public function effectFadeOut(?time:Float = 1){

        alphaTween.cancel();
        alpha = 1;
        alphaTween = FlxTween.tween(this, {alpha: 0}, time);

    }

    public function black(){

        color = 0x000000;

    }

    public function resetColor(){

        color = 0xFFFFFF;

    }

    public function effectFadeIn(?time:Float = 1){

        alphaTween.cancel();
        alpha = 0;
        alphaTween = FlxTween.tween(this, {alpha: 1}, time);

    }

    public function effectExitStageLeft(?time:Float = 1){

        posTween.cancel();
        posTween = FlxTween.tween(this, {x: 0 - width}, time, {ease: FlxEase.circIn});

    }

    public function effectExitStageRight(?time:Float = 1){

        posTween.cancel();
        posTween = FlxTween.tween(this, {x: FlxG.width}, time, {ease: FlxEase.circIn});

    }

    public function effectFlipRight(){

        x = FlxG.width - refx - width;
        y = refy - height;

    }

    public function effectFlipDirection(){
        
        flipX = true;

    }

    public function effectEnterStageLeft(?time:Float = 1){
        
        posTween.cancel();
        var finalX = x;
        x = 0 - width;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.circOut});

    }

    public function effectEnterStageRight(?time:Float = 1){
        
        posTween.cancel();
        var finalX = x;
        x = FlxG.width;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.circOut});
    }

    public function effectToRight(?time:Float = 1){
        
        posTween.cancel();
        var finalX = FlxG.width - refx - width;
        x = refx;
        y = refy - height;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.quintOut});
    }

    public function effectToLeft(?time:Float = 1){
        
        posTween.cancel();
        var finalX = refx;
        x = FlxG.width - refx - width;
        y = refy - height;
        posTween = FlxTween.tween(this, {x: finalX}, time, {ease: FlxEase.quintOut});
    }

   
}
