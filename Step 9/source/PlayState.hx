package;

import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
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
	private var _chaser:FlxSprite;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _grpPBullets:FlxTypedGroup<PBullet>;
	private var _grpEBullets:FlxTypedGroup<EBullet>;
	private var _shootDelay:Float = 0;
	private var _txtScore:FlxText;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		bgColor = 0xff160100;
		
		Reg.score = 0;
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		
		_map = loadMap();
		add(_map);
		
		_sprPlayer = new FlxSprite();
		_sprPlayer.loadGraphic(AssetPaths.player__png, true, 16, 8);
		_sprPlayer.animation.add("normal", [0]);
		_sprPlayer.animation.add("down", [1]);
		_sprPlayer.animation.add("up", [2]);
		_sprPlayer.x = 10;
		_sprPlayer.y = (FlxG.height / 2) - (_sprPlayer.height / 2);
		add(_sprPlayer);
		
		_chaser = new FlxSprite();
		_chaser.makeGraphic(2, 2);
		_chaser.visible = false;
		_chaser.x = FlxG.width / 2 -1;
		_chaser.y = _sprPlayer.y + (_sprPlayer.height / 2) - 1;
		add(_chaser);
		
		add(_grpEnemies);
		
		_grpPBullets = new FlxTypedGroup<PBullet>();
		add(_grpPBullets);
		_grpEBullets = new FlxTypedGroup<EBullet>();
		add(_grpEBullets);
		
		_txtScore = new FlxText(FlxG.width - 202, 2, 200, "0", 8);
		_txtScore.alignment = FlxTextAlign.RIGHT;
		_txtScore.scrollFactor.set();
		add(_txtScore);		
		
		FlxG.camera.setScrollBoundsRect(_map.x,  _map.y, _map.width,  _map.height, true);
		
		FlxG.camera.target = _chaser;
		FlxG.camera.style = FlxCameraFollowStyle.LOCKON;
		
		_chaser.velocity.x = 80;
		
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
				else if (gfxMap.pixels.getPixel(x, y) == 0xff0000)
					_grpEnemies.add(new Enemy(x * 16, y * 16, this));
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
		
		playerMovement();
		
		super.update(elapsed);
		
		collision();
		
		_chaser.y = _sprPlayer.y + (_sprPlayer.height / 2) - 1;
		
		if (_shootDelay > 0)
			_shootDelay -= FlxG.elapsed * 6;
			
		updateScore();
	}
	
	
	private function updateScore():Void
	{
		if (_txtScore.text != Std.string(Reg.score))
		{
			_txtScore.text = Std.string(Reg.score);
		}
	}
	
	private function collision():Void
	{
		FlxG.collide(_sprPlayer, _map,playerHitsWall);
		
		if (_sprPlayer.x < _chaser.x - (FlxG.width / 2) + 8)
		{
			_sprPlayer.x = _chaser.x - (FlxG.width / 2) + 8;
		}
		
		FlxG.overlap(_grpPBullets, _grpEnemies, pBulletHitEnemy);
		FlxG.overlap(_sprPlayer, _grpEnemies, playerHitEnemy);
		FlxG.overlap(_grpEBullets, _sprPlayer, eBulletHitPlayer);
	}
	
	private function eBulletHitPlayer(EB:EBullet, P:FlxSprite):Void
	{
		if (EB.alive)
		{
			EB.kill();
			killPlayer();
		}
	}
	
	private function playerHitEnemy(P:FlxSprite, E:Enemy):Void
	{
		if (E.alive)
		{
			E.kill();
			Reg.score += 100;
			killPlayer();
		}
	}
	private function playerHitsWall(P:FlxSprite, W:FlxTilemap):Void
	{
		killPlayer();
	}
	
	private function killPlayer():Void
	{
		_sprPlayer.kill();
		
		FlxG.switchState(new MenuState());
	}
	
	private function pBulletHitEnemy(PB:PBullet, E:Enemy):Void
	{
		if (PB.alive && E.alive)
		{
			PB.kill();
			E.kill();
			Reg.score += 100;
		}
	}
	
	private function playerMovement():Void
	{
		var v:Float = 0;
		if (FlxG.keys.anyPressed(["UP", "W"]))
			v -= 250;
		if (FlxG.keys.anyPressed(["DOWN", "S"]))
			v += 250;
		if (v < 0)
			_sprPlayer.animation.play("up");
		else if (v > 0)
			_sprPlayer.animation.play("down");
		else
			_sprPlayer.animation.play("normal");
		_sprPlayer.velocity.y = v;
		v = _chaser.velocity.x;
		if (FlxG.keys.anyPressed(["LEFT", "A"]))
			v -= 100;
		if (FlxG.keys.anyPressed(["RIGHT", "D"]))
			v += 100;
		_sprPlayer.velocity.x = v;
		
		if (FlxG.keys.anyPressed(["SPACE", "X"]))
		{
			shootPBullet();
		}
		
	}
	
	public function shootEBullet(E:Enemy):Void
	{
		var eB:EBullet = _grpEBullets.recycle();
		if (eB == null)
			eB = new EBullet();
		eB.reset(E.x -eB.width, E.y +E.height -1);
		_grpEBullets.add(eB);
		
	}
	
	private function shootPBullet():Void
	{
		if (_shootDelay <= 0 && _grpPBullets.countLiving() < 12)
		{
			var pB:PBullet = _grpPBullets.recycle();
			if (pB == null)
				pB = new PBullet();
			pB.reset(_sprPlayer.x + _sprPlayer.width, _sprPlayer.y +_sprPlayer.height -1);
			_grpPBullets.add(pB);
			_shootDelay = .5;
		}
	}
}
