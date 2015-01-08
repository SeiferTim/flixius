package;

import flixel.addons.display.FlxStarField;
import flixel.FlxCamera.FlxCameraFollowStyle;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.graphics.FlxGraphic;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxRandom;
import flixel.text.FlxText;
import flixel.tile.FlxBaseTilemap.FlxTilemapAutoTiling;
import flixel.tile.FlxTilemap;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.ui.FlxButton;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
using flixel.util.FlxSpriteUtil;

/**
 * A FlxState which can be used for the actual gameplay.
 */
class PlayState extends FlxState
{
	
	
	private var _sprPlayer:Player;
	private var _map:FlxTilemap;
	private var _mapDecoTop:FlxTilemap;
	private var _mapDecoBottom:FlxTilemap;
	private var _chaser:FlxSprite;
	private var _grpEnemies:FlxTypedGroup<Enemy>;
	private var _grpPBullets:FlxTypedGroup<PBullet>;
	private var _grpEBullets:FlxTypedGroup<EBullet>;
	private var _shootDelay:Float = 0;
	private var _hits:FlxTypedGroup<Hit>;
	private var _txtScore:FlxText;
	private var _sparks:FlxTypedGroup<Spark>;
	private var _explosions:FlxTypedGroup<Explosion>;
	private var _pThrust:Jet;
	private var _grpEThrust:FlxTypedGroup<Jet>;
	private var _fading:Bool = false;
	private var _healthBar:FlxBar;
	private var _launchedSubstate:Bool = false;
	private var _starting:Bool = true;
	private var _showingReady:Bool = false;
	private var _txtReady:FlxText;
	private var _sprReady:FlxSprite;
	private var _stars:FlxStarField2D;
	
	/**
	 * Function that is called up when to state is created to set it up. 
	 */
	override public function create():Void
	{
		super.create();
		bgColor = 0xff160100;
		
		Reg.score = 0;
		
		_stars = new FlxStarField2D(0, 0, FlxG.width, FlxG.height, 60);
		_stars.bgColor = 0x0;
		_stars.scrollFactor.set();
		_stars.setStarSpeed(0, 0);
		add(_stars);
		
		_grpEnemies = new FlxTypedGroup<Enemy>();
		_grpEThrust = new FlxTypedGroup<Jet>();
		
		loadMaps();
		
		
		
		_sprPlayer = new Player(addExplosions);
		
		_sprPlayer.x = 10;
		_sprPlayer.y = (FlxG.height / 2) - (_sprPlayer.height / 2);
		
		_pThrust = new Jet(_sprPlayer);
		add(_pThrust);
		add(_sprPlayer);
		
		_chaser = new FlxSprite();
		_chaser.makeGraphic(2, 2);
		_chaser.visible = false;
		_chaser.x = FlxG.width / 2 -1;
		_chaser.y = _sprPlayer.y + (_sprPlayer.height / 2) - 1;
		add(_chaser);
		
		
		
		add(_grpEThrust);
		
		add(_grpEnemies);
		
		_grpPBullets = new FlxTypedGroup<PBullet>();
		add(_grpPBullets);
		_grpEBullets = new FlxTypedGroup<EBullet>();
		add(_grpEBullets);
		
		_hits = new FlxTypedGroup<Hit>();
		add(_hits);
		
		_sparks = new FlxTypedGroup<Spark>();
		add(_sparks);
		
		_explosions = new FlxTypedGroup<Explosion>();
		add(_explosions);
		
		_txtScore = new FlxText(FlxG.width - 202, 2, 200, "0", 8);
		_txtScore.alignment = FlxTextAlign.RIGHT;
		_txtScore.scrollFactor.set();
		add(_txtScore);	
		
		_healthBar = new FlxBar(2, 2, FlxBarFillDirection.LEFT_TO_RIGHT, 90, 6, _sprPlayer, "health", 0, 3, true);
		_healthBar.createGradientBar([0xcc111111], [0xffff0000, 0xff00ff00], 1, 0, true, 0xcc333333);
		_healthBar.scrollFactor.set();
		add(_healthBar);
		
		_sprReady = new FlxSprite(0, 0);
		_sprReady.makeGraphic(FlxG.width, Std.int(FlxG.height / 6),FlxColor.RED);
		_sprReady.screenCenter(false, true);
		_sprReady.x = FlxG.width;
		_sprReady.alpha = 0;
		add(_sprReady);
		
		_txtReady  = new FlxText(0, 0, 0, "START!", 48);
		_txtReady.color = FlxColor.YELLOW;
		_txtReady.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLUE, 4, 1);
		_txtReady.italic = true;
		_txtReady.alpha = 0;
		_txtReady.screenCenter(true, true);
		add(_txtReady);
		
		FlxG.camera.setScrollBoundsRect(_map.x,  _map.y, _map.width,  _map.height, true);
		
		FlxG.camera.target = _chaser;
		FlxG.camera.style = FlxCameraFollowStyle.LOCKON;
		
		
		
		
		
	}

	private function loadMaps():Void
	{
		var rnd:FlxRandom = new FlxRandom();
		
		var gfxMap:FlxSprite = new FlxSprite();
		var arrMap:Array<Array<Int>> = [];
		var arrDecoTop:Array<Array<Int>> = [];
		var arrDecoBottom:Array<Array<Int>> = [];
		_map = new FlxTilemap();
		_mapDecoTop = new FlxTilemap();
		_mapDecoBottom = new FlxTilemap();
		
		gfxMap.loadGraphic(AssetPaths.map__png);
		
		var e:Enemy;
		//var et:Jet;
		for (y in 0...Std.int(gfxMap.height))
		{
			arrMap.push([]);
			arrDecoTop.push([]);
			arrDecoBottom.push([]);
			for (x in 0...Std.int(gfxMap.width))
			{
				
				if (gfxMap.pixels.getPixel(x,y) == 0x000000)
				{
					arrMap[y].push(rnd.int(1, 4));
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0x00ff00)
				{
					arrDecoBottom[y].push(rnd.int(1, 9));
					arrDecoTop[y].push(0);
					arrMap[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0xffff00)
				{
					arrDecoTop[y].push(rnd.int(1, 9)+9);
					arrDecoBottom[y].push(0);
					arrMap[y].push(0);
				}
				else if (gfxMap.pixels.getPixel(x, y) == 0xff0000)
				{
					e = new Enemy(x * 16, y * 16, this);
					
					_grpEnemies.add(e);
					_grpEThrust.add(new Jet(e, 1));
					arrMap[y].push(0);
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
				else
				{
					arrMap[y].push(0);
					arrDecoTop[y].push(0);
					arrDecoBottom[y].push(0);
				}
			}
		}
		
		_map.loadMapFrom2DArray(arrMap, AssetPaths.tiles__png, 16, 16, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_mapDecoTop.loadMapFrom2DArray(arrDecoTop, AssetPaths.deco__png, 16, 16, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_mapDecoBottom.loadMapFrom2DArray(arrDecoBottom, AssetPaths.deco__png, 16, 16, FlxTilemapAutoTiling.OFF, 1, 1, 1);
		_mapDecoTop.y -= 4;
		_mapDecoBottom.y += 4;
		
		
		add(_map);
		add(_mapDecoTop);
		add(_mapDecoBottom);
	}
	
	/**
	 * Function that is called when this state is destroyed - you might want to 
	 * consider setting all objects this state uses to null to help garbage collection.
	 */
	override public function destroy():Void
	{
		super.destroy();
	}
	
	
	public function returnFromSubState():Void
	{
		_showingReady = true;
		
		FlxTween.num(0, 1, .1, { type:FlxTween.ONESHOT, ease:FlxEase.sineOut, onComplete:function(_) {
			FlxTween.num(0, 1, .2, { type:FlxTween.ONESHOT, ease:FlxEase.sineOut, onComplete:function(_) {
				FlxTween.num(1, .2, .2, { type:FlxTween.ONESHOT, ease: FlxEase.sineInOut, onComplete:function (_) {
					FlxTween.num(.2, 1, .2, { type:FlxTween.ONESHOT, ease: FlxEase.sineInOut, onComplete:function (_) {
						FlxTween.num(1, .2, .2, { type:FlxTween.ONESHOT, ease: FlxEase.sineInOut, onComplete:function (_) {
							FlxTween.num(.2, 1, .2, { type:FlxTween.ONESHOT, ease: FlxEase.sineInOut, onComplete:function (_) {
								FlxTween.num(1, 0, .2, { type:FlxTween.ONESHOT, ease: FlxEase.sineIn, onComplete:function (_) {
									FlxG.camera.flash(FlxColor.WHITE,.2,function() {
										FlxTween.num(1,0,.1, { type: FlxTween.ONESHOT,ease:FlxEase.sineIn,onComplete:function (_){									
											_starting = false;
											_showingReady = false;
											_chaser.velocity.x = 80;
											_stars.setStarSpeed(60, 160);
										}},readyBoxAlphaOut);
									});
								}},readyAlpha);
							}},readyAlpha);
						}},readyAlpha);
					}},readyAlpha);
				}},readyAlpha);
			}},readyAlpha);
		}}, readyBoxAlphaIn);
	}
	
	private function readyAlpha(A:Float):Void
	{
		_txtReady.alpha = A;
	}
	
	private function readyBoxAlphaIn(A:Float):Void
	{
		_sprReady.alpha = A*.8;
		_sprReady.x = FlxG.width * (1-A);
	}
	
	private function readyBoxAlphaOut(A:Float):Void
	{
		_sprReady.alpha = A*.8;
		_sprReady.x = -FlxG.width * (1-A);
	}
	
	/**
	 * Function that is called once every frame.
	 */
	override public function update(elapsed:Float):Void
	{
		
		
		super.update(elapsed);
		
		
		if (_starting)
		{
			if (!_launchedSubstate)
			{
				_launchedSubstate = true;
				openSubState(new MessagePopup(returnFromSubState));
			}
		}
		else
		{
			
			if (_sprPlayer.alive)
			{
				if (!_sprPlayer.dying)
				{
					playerMovement();
					
					collision();
					
					_chaser.y = _sprPlayer.y + (_sprPlayer.height / 2) - 1;
					
					if (_shootDelay > 0)
						_shootDelay -= FlxG.elapsed * 6;
				}
				else
				{
					_sprPlayer.velocity.x = 40;
					_sprPlayer.velocity.y = 40;
					
				}
			}
			else
			{
				if (!_fading)
				{
					_fading = true;
					FlxG.camera.fade(FlxColor.BLACK, .8, false, function() {
						FlxG.switchState(new MenuState());
					});
				}
			}
			
				
			updateScore();
		
		}
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
			spawnHit();
			P.hurt(1);
			FlxG.camera.flash(FlxColor.WHITE, .1);
		}
	}
	
	private function spawnHit():Void
	{
		var h:Hit = _hits.recycle();
		if (h == null)
		{
			h = new Hit(_sprPlayer);
		}
		h.hit();
		_hits.add(h);
	}
	
	private function playerHitEnemy(P:FlxSprite, E:Enemy):Void
	{
		if (E.alive)
		{
			E.kill();
			addExplosions(E);
			FlxG.camera.flash(FlxColor.WHITE, .1);
			Reg.score += 100;
			_sprPlayer.hurt(1);
		}
	}
	private function playerHitsWall(P:FlxSprite, W:FlxTilemap):Void
	{
		_sprPlayer.kill();
		FlxG.camera.flash(FlxColor.WHITE, .1);
	}
	
	
	private function pBulletHitEnemy(PB:PBullet, E:Enemy):Void
	{
		if (PB.alive && E.alive)
		{
			PB.kill();
			E.kill();
			addExplosions(E);
			Reg.score += 100;
			
		}
	}
	
	private function addExplosions(Target:FlxSprite):Void
	{
		var e:Explosion;
		for (i in 0...3)
		{
			e = _explosions.recycle();
			if (e == null)
			{
				e = new Explosion();
			}
			e.explode(Target, i);
			_explosions.add(e);
		}
	}
	
	private function playerMovement():Void
	{
		var v:Float = 0;
		if (FlxG.keys.anyPressed(["UP", "W"]))
			v -= 120;
		if (FlxG.keys.anyPressed(["DOWN", "S"]))
			v += 120;
		if (v < 0)
			_sprPlayer.animation.play("up");
		else if (v > 0)
			_sprPlayer.animation.play("down");
		else
			_sprPlayer.animation.play("normal");
		_sprPlayer.velocity.y = v;
		v = _chaser.velocity.x;
		if (FlxG.keys.anyPressed(["LEFT", "A"]))
			v -= 90;
		if (FlxG.keys.anyPressed(["RIGHT", "D"]))
			v += 90;
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
		FlxG.sound.play(AssetPaths.eshoot__wav);
		var s:Spark = _sparks.recycle();
		if (s == null)
			s = new Spark();
		s.spark(-1, E.height-2, E,1);
		_sparks.add(s);
		
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
			FlxG.sound.play(AssetPaths.shoot__wav);
			var s:Spark = _sparks.recycle();
			if (s == null)
				s = new Spark();
			s.spark(_sprPlayer.width-1,_sprPlayer.height -2,_sprPlayer, 0);
			_sparks.add(s);
		}
	}
}
