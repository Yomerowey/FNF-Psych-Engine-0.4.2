package;

//This made by Sirox for using with whatever you want
import haxe.crypto.Md5;
import openfl.utils.Assets;
import webm.*;
import flixel.system.FlxSound;
import flixel.FlxCamera;
import openfl.Assets;
import openfl.media.Sound;
import flixel.FlxSprite;
import flixel.FlxG;
import openfl.Lib;
#if sys
import sys.FileSystem;
import sys.io.File;
import Sys;
#end

using StringTools;

class WebmPlayerS extends FlxSprite
{
	public var videoplayer:WebmPlayer;
	public var endcallback:Void->Void = null;
	public var startcallback:Void->Void = null;
	public var sound:FlxSound;
    public var soundMultiplier:Float = 1;
    public var prevSoundMultiplier:Float = 1;
    public var videoFrames:Int = 0;
    public var doShit:Bool = false;
    public var io:WebmIo;
    public var altSource:String;
    
    public var stopped:Bool = false;
	public var restarted:Bool = false;
	public var started:Bool = false;
	public var ended:Bool = false;
	public var paused:Bool = false;
	
	public var useSound:Bool = false;
	
	public function new(source:String, ownCamera:Bool = false, frameSkipLimit:Int = -1, okX:Float = null, okY:Float = null, okWidth:Float = null, okHeight:Float = null) 
    {
    	x = 0;
        y = 0;

    	if (okX != null) {
        	x = okX;
        }
        if (okY != null) {
        	y = okY;
        }
        if (okWidth != null) {
        	width = okWidth;
        }
        if (okHeight != null) {
        	height = okHeight;
        }

        super(x, y);
        
        altSource = source;
        
        useSound = Assets.exists(altSource.replace(".webm", ".txt")) && Assets.exists(altSource.replace(".webm", ".ogg"));
        
        if (useSound) {
            videoFrames = Std.parseInt(Assets.getText(altSource.replace(".webm", ".txt")));
        }
        
        io = new WebmIoFile(getThing(altSource));
		videoplayer = new WebmPlayer();
		videoplayer.fuck(io, false);
		videoplayer.addEventListener(WebmEvent.PLAY, function(e) {
			trace("playing");
			if (startcallback != null) {
				startcallback();
			}
			started = true;
		});
		videoplayer.addEventListener(WebmEvent.COMPLETE, function(e) {
			trace("ended");
			if (endcallback != null) {
				endcallback();
			}
			ended = true;
		});
		videoplayer.addEventListener(WebmEvent.STOP, function(e) {
			trace("stopped");
			stopped = true;
		});
		videoplayer.addEventListener(WebmEvent.RESTART, function(e) {
			trace("restarted");
			restarted = true;
		});
		
		loadGraphic(videoplayer.bitmapData);
		
		if (useSound) {
		    sound = FlxG.sound.play(altSource.replace(".webm", ".ogg"));
		    sound.time = sound.length * soundMultiplier;
		    doShit = true;
		}
        
      
		
		if (ownCamera) {
		    var cam = new FlxCamera();
	        FlxG.cameras.add(cam);
		    cam.bgColor.alpha = 0;
		    cameras = [cam];
		}
    }
    
    public function getThing(source:String)
    {
    	#if mobile
        return AndroidThing.getPath(source);
        #elseif desktop
        return Sys.getCwd() + source;
        #else
        return null;
        #end
    }
	
	public function play():Void
	{
		videoplayer.play();
	}
	
	public function stop():Void
	{
		videoplayer.stop();
	}
	
	public function restart():Void
	{
		videoplayer.restart();
	}
	
	public function togglePause():Void
	{
		if (paused)
		{
			resume();
		} else {
			pause();
		}
	}
	
	public function clearPause():Void
	{
		paused = false;
		videoplayer.removePause();
	}
	
	public function pause():Void
	{
		videoplayer.changePlaying(false);
		paused = true;
	}
	
	public function resume():Void
	{
		videoplayer.changePlaying(true);
		paused = false;
	}
	
	public function setAlpha(ok:Float):Void
	{
		videoplayer.alpha = ok;
	}
	
	override public function update(elapsed:Float)
	{
		super.update(elapsed);
		
		if (useSound)
		{
			var wasFuckingHit = videoplayer.wasHitOnce;
			soundMultiplier = videoplayer.renderedCount / videoFrames;
			
			if (soundMultiplier > 1)
			{
				soundMultiplier = 1;
			}
			if (soundMultiplier < 0)
			{
				soundMultiplier = 0;
			}
			if (doShit)
			{
				var compareShit:Float = 50;
				if (sound.time >= (sound.length * soundMultiplier) + compareShit || sound.time <= (sound.length * soundMultiplier) - compareShit)
					sound.time = sound.length * soundMultiplier;
			}
			if (wasFuckingHit)
			{
			if (soundMultiplier == 0)
			{
				if (prevSoundMultiplier != 0)
				{
					sound.pause();
					sound.time = 0;
				}
			} else {
				if (prevSoundMultiplier == 0)
				{
					sound.resume();
					sound.time = sound.length * soundMultiplier;
				}
			}
			prevSoundMultiplier = soundMultiplier;
			}
		}
	}
	
	override public function destroy() {
        videoplayer.stop();
        super.destroy();
    }
}

class Dimensions
{
	public static var width:Int = 1280;
	public static var height:Int = 720;
}

class AndroidThing
{
	#if android
	static var path:String = lime.system.System.applicationStorageDirectory;
	#end

	public static function getPath(id:String)
	{
		#if android
		var file = Assets.getBytes(id);

		var md5 = Md5.encode(Md5.make(file).toString());

		if (FileSystem.exists(path + md5))
			return path + md5;


		File.saveBytes(path + md5, file);

		return path + md5;
		#else
		return null;
		#end
	}
}
