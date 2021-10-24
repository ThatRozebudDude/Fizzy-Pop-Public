package;

import title.*;
import config.*;

import flixel.FlxState;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.graphics.FlxGraphic;
import flixel.addons.transition.TransitionData;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.text.FlxText;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;

using StringTools;

class Startup extends FlxState
{

    var nextState:FlxState = new TitleScreen();

    var splash:FlxSprite;
    //var dummy:FlxSprite;
    var loadingText:FlxText;

    var songsCached:Bool;
    var songs:Array<String> =   ["Popped", "Fizzed", "Glamour"];
                                
    //List of character graphics and some other stuff.
    //Just in case it want to do something with it later.
    var charactersCached:Bool;
    var characters:Array<String> =   ["BOYFRIEND",
                                    "GF_assets", "soda/gf-cola",
                                    "soda/fizzy", "soda/bunga"];

    var graphicsCached:Bool;
    var graphics:Array<String> =    ["logoBumpin", "titleBG", "gfDanceTitle", "titleEnter",
                                    "FIZZ_BG"];

    var cacheStart:Bool = false;

    public static var thing = false;

	override function create()
	{

        FlxG.mouse.visible = false;
        FlxG.sound.muteKeys = null;

        FlxG.save.bind('data');
		Highscore.load();
		KeyBinds.keyCheck();
		PlayerSettings.init();

        PlayerSettings.player1.controls.loadKeyBinds();
		Config.configCheck();

        var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
        diamond.persist = true;
        diamond.destroyOnNoUse = false;
        
        FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), 
            {asset: diamond, width: 32, height: 32},  new FlxRect(-400, -200, FlxG.width * 2, FlxG.height * 1.5));
        FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
            {asset: diamond, width: 32, height: 32}, new FlxRect(-400, -200, FlxG.width * 2, FlxG.height * 1.5));

        if (FlxG.save.data.weekUnlocked != null)
		{
			// FIX LATER!!!
			// WEEK UNLOCK PROGRESSION!!
			// StoryMenuState.weekUnlocked = FlxG.save.data.weekUnlocked;

			if (StoryMenuState.weekUnlocked.length < 4)
				StoryMenuState.weekUnlocked.insert(0, true);

			// QUICK PATCH OOPS!
			if (!StoryMenuState.weekUnlocked[0])
				StoryMenuState.weekUnlocked[0] = true;
		}

        if( FlxG.save.data.musicPreload == null ||
            FlxG.save.data.charPreload == null ||
            FlxG.save.data.graphicsPreload == null)
        {
            openPreloadSettings();
        }
        else{
            songsCached = !FlxG.save.data.musicPreload;
            charactersCached = !FlxG.save.data.charPreload;
            graphicsCached = !FlxG.save.data.graphicsPreload;
        }

        splash = new FlxSprite(0, 0);
        splash.frames = Paths.getSparrowAtlas('fpsPlus/rozeSplash');
        splash.animation.addByPrefix('start', 'Splash Start', 24, false);
        splash.animation.addByPrefix('end', 'Splash End', 24, false);
        add(splash);
        splash.animation.play("start");
        splash.updateHitbox();
        splash.screenCenter();

        loadingText = new FlxText(5, FlxG.height - 30, 0, "", 24);
        loadingText.setFormat(Paths.font("vcr"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        add(loadingText);

        #if web
        FlxG.sound.play(Paths.sound("tick"), 0);   
        #end

        new FlxTimer().start(1.1, function(tmr:FlxTimer)
        {
            FlxG.sound.play(Paths.sound("splashSound"));   
        });

        super.create();

    }

    override function update(elapsed) 
    {
        
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "start" && !cacheStart){
            
            #if web
            new FlxTimer().start(1.5, function(tmr:FlxTimer)
            {
                songsCached = true;
                charactersCached = true;
                graphicsCached = true;
            });
            #else
            preload(); 
            #end
            
            cacheStart = true;
        }
        if(splash.animation.curAnim.finished && splash.animation.curAnim.name == "end"){
            FlxG.switchState(nextState);  
        }

        if(songsCached && charactersCached && graphicsCached && splash.animation.curAnim.finished && !(splash.animation.curAnim.name == "end")){
            
            splash.animation.play("end");
            splash.updateHitbox();
            splash.screenCenter();

            new FlxTimer().start(0.3, function(tmr:FlxTimer)
            {
                loadingText.text = "Done!";
            });
        }

        if(!cacheStart && FlxG.keys.justPressed.O){
            
           
            openPreloadSettings();

        }
        
        super.update(elapsed);

    }

    function preload(){

        loadingText.text = "Preloading Assets...";

        
        if(!songsCached){ 
            #if sys sys.thread.Thread.create(() -> { #end
                preloadMusic();
            #if sys }); #end
        }

        if(!charactersCached){
            #if sys sys.thread.Thread.create(() -> { #end
                preloadCharacters();
            #if sys }); #end
        }

        if(!graphicsCached){
            #if sys sys.thread.Thread.create(() -> { #end
                preloadGraphics();
            #if sys }); #end
        }

    }

    function preloadMusic(){
        for(x in songs){
            FlxG.sound.cache(Paths.music(x + "_Inst"));
            //trace("Chached " + x);
        }
        FlxG.sound.cache(Paths.music("popMenu"));
        
        loadingText.text = "Songs cached...";
        songsCached = true;
    }

    function preloadCharacters(){
        for(x in characters){
            ImageCache.add(Paths.image(x));
            //trace("Chached " + x);
        }
        loadingText.text = "Characters cached...";
        charactersCached = true;
    }

    function preloadGraphics(){
        for(x in graphics){
            ImageCache.add(Paths.image(x));
            //trace("Chached " + x);
        }
        loadingText.text = "Graphics cached...";
        graphicsCached = true;
    }

    function openPreloadSettings(){
        #if desktop
        CacheSettings.noFunMode = true;
        FlxG.switchState(new CacheSettings());
        CacheSettings.returnLoc = new Startup();
        #end
    }

}
