package ;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.system.FlxAssets.FlxGraphicAsset;

class Player extends FlxSprite
{

	public var dying:Bool = false;
	private var _dyingTimer:Float = 2;
	private var _deathCallback:FlxSprite->Void;
	
	public function new(DeathCallback:FlxSprite->Void) 
	{
		super(0, 0);
		loadGraphic(AssetPaths.player__png, true, 16, 8);
		animation.add("normal", [0]);
		animation.add("down", [1]);
		animation.add("up", [2]);
		health = 3;
		_deathCallback = DeathCallback;
		
	}
	
	override public function kill():Void 
	{
		health = 0;
		dying = true;
		_dyingTimer = 1;
		
		_deathCallback(this);
	}
	
	override public function update(elapsed:Float):Void 
	{
		super.update(elapsed);
		if (dying)
		{
			if (_dyingTimer > 0)
			{
				_dyingTimer -= FlxG.elapsed*2;
				alpha = _dyingTimer;
			}
			else
			{
				alive = false;
				exists = false;
			}
		}
	}
	
	
	
}