package balance
{
	import Box2D.Collision.b2AABB;
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2DebugDraw;
	import Box2D.Dynamics.b2World;
	
	import as3.AssetManager.AssetManager;
	
	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;
	import flash.utils.setTimeout;

	public class GameManager extends Sprite
	{
		public static var dbgText : TextField;
		
		public static var dictionary : Dictionary;
		
		
		private var testScoreTimer : Timer
		public var sensorActive : Boolean = false;
		public var ascii : Array;
		public var powerUps : Array;
		private var m_iterations:int = 50;
		private var m_timeStep:Number = 1.0/30.0;
		
		private var m_world : b2World;
		private var m_gameObjects : Array;
		private var m_players : Array;
		public var m_platform : Platform;
		private var m_platformHeight : Number;
		private var m_playerDef : Array;
		private var m_keyMap : Object;
		
		public function GameManager(playerDef : Array = null)
		{
			m_playerDef = playerDef
			powerUps = new Array();
			powerUps[0] = "bla"; //this solves a really odd bug
			m_keyMap = new Object();
			m_gameObjects = new Array();
			m_players = new Array();
			addEventListener(Event.ADDED_TO_STAGE, addedHandler)
			fillAscii()
		}
		
		private function addedHandler(e : Event) : void {
			// Load all parameters into dictionary
			dictionary = new Dictionary('dict.xml');
			dictionary.loader.addEventListener(Event.COMPLETE, continueGameLoading);
		}
		
		private function continueGameLoading(e:Event) : void {
			stage.focus = this; //key focus
			addEventListener(Event.ENTER_FRAME, Update);
			stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
			stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
			
			initWorld();
			initGameObjects();
			initDebugDraw();
			initStageGraphics();
			
			setTimeout(addBlock,Math.random()*1000);
			setTimeout(addPowerUp,Math.random()*1000);			
		}
		
		public function get players():Array {
			return m_players
		}
		
		
		//PowerUps are not physical objects
		private function addPowerUp() : void {
			var rnd : uint = Math.floor(Math.random()*5)
			var color : uint;
			var type : String;
			switch(rnd) {
				case 0:
					type = "weight++"
					color = 0xffffff;
				break;
				case 1:
					type = "weight--"
					color = 0x0;
				break;
				case 2:
					type = "speed++"
					color = 0x00ff00;
				break;
				case 3:
					type = "pull"
					color = 0xf0000f;
				break;
				case 4:
					type = "push"
					color = 0x000ff0;
				break;
			}
			var powerUp : MovieClip = new MovieClip();
			
			powerUp.graphics.lineStyle(2);
			powerUp.graphics.beginFill(color)
			powerUp.graphics.drawRect(-15,-15,30,30);
			powerUp.graphics.endFill();
			
			powerUp.x = Math.random()*600-300;
			powerUp.y = (Math.random()<0.5)?-(m_platformHeight/2+powerUp.height/2):-100;
			powerUp.type = type;
			powerUps.push(powerUp);
			m_platform.addChild(powerUp)
			setTimeout(addPowerUp,Math.random()*10000+10000)
		} 
		
		private function addBlock() : void {
			var block : Block = new Block(m_world,new b2Vec2(Math.random()*30+5,15));
			m_gameObjects.push(block);
			addChild(block)
			setTimeout(addBlock,Math.random()*10000+10000)
		} 
		
		private function initWorld() : void 
		{
			var worldAABB:b2AABB = new b2AABB();
			worldAABB.lowerBound.Set(0, 0);
			worldAABB.upperBound.Set(
				stage.stageWidth / 
					Number(GameManager.dictionary.getParamByName('worldScale')),
				stage.stageHeight / 
					Number(GameManager.dictionary.getParamByName('worldScale')));
			var gravity:b2Vec2 = new b2Vec2(0, 35);
			var doSleep:Boolean = true;
			m_world = new b2World(worldAABB, gravity, doSleep);
			m_world.SetContactListener(new ContactListener(this));
		}
		
		private function initGameObjects() : void
		{
			var obj : GameObject;
			obj = new Platform(m_world)
			m_platform = Platform(obj);
			m_gameObjects.push(obj);
			m_platformHeight = 20;
			for(var i : uint = 0 ; i < m_playerDef.length ; ++i) {
				// If it is a human player
				if (m_playerDef[i].type == "human")
				{
					obj = new Player(m_world, new b2Vec2(13+((27-13)/m_playerDef.length)*i,5),this,
								 m_playerDef[i].team,
								 m_playerDef[i].name);
				}
				// Else - it's a bot
				else
				{
					obj = new Bot(m_world, new b2Vec2(13+((27-13)/m_playerDef.length)*i,5),this,
								 m_playerDef[i].team,
								 m_playerDef[i].name,
								 m_playerDef[i].controlls);
				}
				
								 	   
				m_gameObjects.push(obj);
				m_players.push(obj);
				//trace(m_playerDef[i].controlls)
				m_keyMap[m_playerDef[i].controlls[0]] = {index:i, func:"left"}
				m_keyMap[m_playerDef[i].controlls[1]] = {index:i, func:"right"}
				m_keyMap[m_playerDef[i].controlls[2]] = {index:i, func:"up"}
				m_keyMap[m_playerDef[i].controlls[3]] = {index:i, func:"down"}
			}
			
			m_gameObjects.forEach(_add)
			function _add(item : DisplayObject , ...prams) : void {
				addChild(item);
			}
		}
		
		private function initStageGraphics():void {
			var tmpMC : MovieClip = AssetManager.getInstance().getAssetByName('clouds_gui');
			tmpMC.x = this.width / 2;
			tmpMC.y = this.height * 0.15;
			addChild(tmpMC);
		} 
		
		private function initDebugDraw() : void {
			var dbgDraw:b2DebugDraw = new b2DebugDraw();
			var dbgSprite:Sprite = new Sprite();
			addChild(dbgSprite);
			dbgDraw.m_sprite = dbgSprite;
			dbgDraw.m_drawScale = Number(GameManager.dictionary.getParamByName('worldScale'));
			dbgDraw.m_fillAlpha = 0.2;
			dbgDraw.m_lineThickness = 1.0;
			dbgDraw.AppendFlags(b2DebugDraw.e_shapeBit)
			//dbgDraw.AppendFlags(b2DebugDraw.e_shapeBit)
			m_world.SetDebugDraw(dbgDraw);
			
			dbgText = new TextField();
			dbgText.x = 10; dbgText.y = 10;
			dbgText.autoSize = TextFieldAutoSize.LEFT;
			dbgSprite.addChild(dbgText);
		}
		
		public function startCalculatingScore() : void {
			testScoreTimer = new Timer(200,0);
			testScoreTimer.addEventListener(TimerEvent.TIMER, function tick(e:Event):void {
				if (sensorActive) {
					if (m_platform.rotation < 0) {
						dbgText.text = "RED SCORES: " + Math.random().toString();
					} else {
						dbgText.text = "BLUE SCORES: " + Math.random().toString();
					}
				}
				else
				{
					testScoreTimer.stop();
				}
			});
			testScoreTimer.start();
		}
		
		public function stopCalculatingScore() : void {
			testScoreTimer.stop();
			sensorActive = false;
		}
		
		public function Update(e:Event = null):void
		{
			//dbgText.text = m_platform.rotation.toString();
			
			m_world.Step(m_timeStep, m_iterations);
			m_world.m_gravity = new b2Vec2(35*Math.cos(m_platform.bodies[0].GetAngle()+Math.PI/2),35*Math.sin(m_platform.bodies[0].GetAngle()+Math.PI/2))
			
			for each(var obj : GameObject in m_gameObjects){
				obj.update();
				//respawn frozen players
				if(obj.isFrozen) {
					if (obj is Bot) {
						var brespawn : Bot = new Bot(m_world,Bot(obj).spawn_point,this,Bot(obj).team,Bot(obj).pname, Bot(obj).controlsKeys);
						m_gameObjects.splice(m_gameObjects.indexOf(obj),1,brespawn)
						m_players.splice(m_players.indexOf(obj),1,brespawn)
						addChild(brespawn)
					}
					else if(obj is Player)
					{
						dispatchEvent(new BalanceEvent(BalanceEvent.SET_POWERUP,Player(obj).pname,Player(obj).team,"none",0))
						var prespawn : Player = new Player(m_world,Player(obj).spawn_point,this,Player(obj).team,Player(obj).pname)
						m_gameObjects.splice(m_gameObjects.indexOf(obj),1,prespawn)
						m_players.splice(m_players.indexOf(obj),1,prespawn)
						addChild(prespawn)
					}
					else
					{
						m_gameObjects.splice(m_gameObjects.indexOf(obj),1);
					}
					
					// Remove frozen object from stage
					removeChild(obj);
					
					// Also remove from the world
					obj.bodies.forEach(function removeLoop(body:*, ...params){
						m_world.DestroyBody(body);						
					});
				}
				
				// If it's a bot - let him perform a move
				if (obj is Bot)
				{
					Bot(obj).doMove();
				}
			}	
		}
		
		private function keyDownHandler(e : KeyboardEvent) : void {
			preformKeydown(ascii[e.keyCode])
		}
		
		public function preformKeydown(s : String) : void {
			var action : Object = m_keyMap[s];
			if(action == null)
				return;
			var player : Player = m_players[action.index]
			switch(action.func) {
				case "left":
					player.speed = 5;
					break;
				case "right":
					player.speed = -5;
					break;
				case "up":
					/*if(!player.isJumping)
						if(player.contactCount > 0) {
							player.jump();
							player.isJumping = true;
						}*/
						
					if (player.contactCount > 0)
						player.jump();
					break;
				case "down":
					player.usePowerUp()
					break;
			}
		}
		
		private function keyUpHandler(e : KeyboardEvent) : void {
			preformKeyup(ascii[e.keyCode])
		}
		
		public function preformKeyup(s : String) : void {
			var action : Object = m_keyMap[s];
			if(action == null)
				return;
			var player : Player = m_players[action.index]
			switch(action.func) {
				case "left":
				case "right":
					player.speed = 0;
					break;
			}
		}

		private function fillAscii(){
			ascii = new Array();
			ascii[65] = "A";
			ascii[66] = "B";
			ascii[67] = "C";
			ascii[68] = "D";
			ascii[69] = "E";
			ascii[70] = "F";
			ascii[71] = "G";
			ascii[72] = "H";
			ascii[73] = "I";
			ascii[74] = "J";
			ascii[75] = "K";
			ascii[76] = "L";
			ascii[77] = "M";
			ascii[78] = "N";
			ascii[79] = "O";
			ascii[80] = "P";
			ascii[81] = "Q";
			ascii[82] = "R";
			ascii[83] = "S";
			ascii[84] = "T";
			ascii[85] = "U";
			ascii[86] = "V";
			ascii[87] = "W";
			ascii[88] = "X";
			ascii[89] = "Y";
			ascii[90] = "Z";
			ascii[48] = "0";
			ascii[49] = "1";
			ascii[50] = "2";
			ascii[51] = "3";
			ascii[52] = "4";
			ascii[53] = "5";
			ascii[54] = "6";
			ascii[55] = "7";
			ascii[56] = "8";
			ascii[57] = "9";
			ascii[32] = "Spacebar";
			ascii[17] = "Ctrl";
			ascii[16] = "Shift";
			ascii[192] = "~";
			ascii[38] = "up";
			ascii[40] = "down";
			ascii[37] = "left";
			ascii[39] = "right";
			ascii[96] = "Numpad 0";
			ascii[97] = "Numpad 1";
			ascii[98] = "Numpad 2";
			ascii[99] = "Numpad 3";
			ascii[100] = "Numpad 4";
			ascii[101] = "Numpad 5";
			ascii[102] = "Numpad 6";
			ascii[103] = "Numpad 7";
			ascii[104] = "Numpad 8";
			ascii[105] = "Numpad 9";
			ascii[111] = "Numpad /";
			ascii[106] = "Numpad *";
			ascii[109] = "Numpad -";
			ascii[107] = "Numpad +";
			ascii[110] = "Numpad .";
			ascii[45] = "Insert";
			ascii[46] = "Delete";
			ascii[33] = "Page Up";
			ascii[34] = "Page Down";
			ascii[35] = "End";
			ascii[36] = "Home";
			ascii[112] = "F1";
			ascii[113] = "F2";
			ascii[114] = "F3";
			ascii[115] = "F4";
			ascii[116] = "F5";
			ascii[117] = "F6";
			ascii[118] = "F7";
			ascii[119] = "F8";
			ascii[188] = ",";
			ascii[190] = ".";
			ascii[186] = ";";
			ascii[222] = "'";
			ascii[219] = "[";
			ascii[221] = "]";
			ascii[189] = "-";
			ascii[187] = "+";
			ascii[220] = "\\";
			ascii[191] = "/";
			ascii[9] = "TAB";
			ascii[8] = "Backspace";
			//ascii[27] = "ESC";
		}
	}
}