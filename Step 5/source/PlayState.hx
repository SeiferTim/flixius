package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	
	private var _sprPlayer:FlxSprite;
	private var _map:FlxTilemap;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		
		_map = loadMap();
		add(_map);
		
		_sprPlayer = new FlxSprite();
		_sprPlayer.makeGraphic(16, 8, FlxColor.GRAY);
		_sprPlayer.x = 10;
		_sprPlayer.y = (FlxG.height / 2) - (_sprPlayer.height / 2);
		add(_sprPlayer);
		
		
		
		
	}
	
	private function loadMap():FlxTilemap
	{
		var gfxMap:FlxSprite = new FlxSprite();
		var arrMap:Array<Array<Int>> = [];
		var map:FlxTilemap = new FlxTilemap();
		
		gfxMap.loadGraphic(AssetPaths.map__png);
		
		for (y in 0...Std.int(gfxMap.height))
		{
			arrMap.push([]);
			for (x in 0...Std.int(gfxMap.width))
			{
				if (gfxMap.pixels.getPixel(x,y) == 0x000000)
					arrMap[y].push(1);
				else
					arrMap[y].push(0);
			}
		}
		
		map.loadMapFrom2DArray(arrMap, AssetPaths.tiles__png, 16, 16, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		return map;
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
		
		collision();
		
		
		
		
	}
	
	
	private function collision():Void
	{
		FlxG.collide(_sprPlayer, _map);
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
