package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	
	private var _sprPlayer:FlxSprite;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		_sprPlayer = new FlxSprite();
		_sprPlayer.makeGraphic(16, 8, FlxColor.GRAY);
		add(_sprPlayer);
		
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}

	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		super.update(elapsed);
		
		playerMovement();
		
	}
	
	
	private function playerMovement():Void
	{
		var v:Float = 0;
		if (FlxG.keys.anyPressed(["UP", "W"]))
			v -= 250;
		if (FlxG.keys.anyPressed(["DOWN", "S"]))
			v += 250;
		_sprPlayer.velocity.y = v;
		v = 0;
		if (FlxG.keys.anyPressed(["LEFT", "A"]))
			v -= 100;
		if (FlxG.keys.anyPressed(["RIGHT", "D"]))
			v += 100;
		_sprPlayer.velocity.x = v;
	}
}
