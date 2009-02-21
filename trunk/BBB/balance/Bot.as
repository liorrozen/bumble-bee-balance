package balance
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	
	import flash.display.*;
	import flash.geom.Point;

	public class Bot extends Player
	{
		private var prevMove : String = "R";
		public var playMode : uint;
		public var controlsKeys : Array = null;
		
		private const KEY_LEFT_IDX : uint = 0;
		private const KEY_RIGHT_IDX : uint = 1;
		private const KEY_UP_IDX : uint = 2;
		private const KEY_DOWN_IDX : uint = 3;
		
		private var m_direction : int;
		private var m_directionKey : uint;
		private var m_oppositeDirectionKey : int;
		private var m_location : Point;
		private var m_rotation : Number;
		private var m_players : Array;
		private var m_blocks : Array;
		private var m_powerups : Array;
		
		//holds the most positive block rotation value for keeping the blocks on your side from being pushed from the edge
		private var m_mostPositiveBlockRotation : Number; 
		
		private var beStill : Boolean = false;
		
		public function Bot(world:b2World, position : b2Vec2,
							manager : GameManager,
							p_team : uint, p_name : String,
							controls : Array,
							playMode : String)
		{
			this.playMode = Number(playMode);
			controlsKeys = controls;
			
			//resolve winning direction by team
			if(Number(p_team) == 1)	m_direction = 1;
			else					m_direction = -1;
			//resolve direction key by direction
			if(m_direction == 1){
				m_directionKey = KEY_RIGHT_IDX;
				m_oppositeDirectionKey = KEY_LEFT_IDX;
			}
			else{
				m_directionKey = KEY_LEFT_IDX;
				m_oppositeDirectionKey = KEY_RIGHT_IDX;
			}
			
			m_mostPositiveBlockRotation = 0;
			
			super(world, position, manager, p_team, p_name);
		}
		
		//resolve object types and distances into bot's sight arrays
		private function UpdateWorldSnapshot(gameObjects : Array, gamePowerups : Array) : void
		{
			//get self X location (including direction) from platform center
			m_location.x = (m_body.GetPosition().x - 20) * Number(GameManager.dictionary.getParamByName('worldScale')) * m_direction;
			//get self Y location
			m_location.y = m_body.GetPosition().y * Number(GameManager.dictionary.getParamByName('worldScale'));
			m_rotation = m_body.GetAngle() * (180/Math.PI);
			
			var block_location : int = 0;
			var block_rotation : int = 0;
			var positiveBlockFound : Boolean = false;
			
			//get world objects locations
			for each(var gObj : GameObject in gameObjects){
				//dont pay attention to bots from your team (yet...)
				if(gObj is Player && ((Player)(gObj)).team == this.team)	continue;
				//distance from rival
				else if(gObj is Player)	m_players.push((m_location.x - ((GameObject)(gObj)).BodyX) * Number(GameManager.dictionary.getParamByName('worldScale')));
				//block distance (including direction) from platform center 
				else if(gObj is Block){
					block_location = (((GameObject)(gObj)).BodyX - 20) * Number(GameManager.dictionary.getParamByName('worldScale')) * m_direction;
					m_blocks.push(block_location);
					
					block_rotation = ((GameObject)(gObj)).BodyRotation;
					//find the most positive block rotation (for edge calculations later)
					if(block_location > 0 && block_location > m_location.x){
						m_mostPositiveBlockRotation = block_rotation;
						positiveBlockFound = true;
					}
				}
			}
			
			if(!positiveBlockFound)	m_mostPositiveBlockRotation = 0;	//zero if none found
			
			//distance from powerups
			for each(var pObj : Object in gamePowerups){
				if(pObj is MovieClip)	m_powerups.push((m_location.x - ((MovieClip)(pObj)).x) * Number(GameManager.dictionary.getParamByName('worldScale')));
			}
		}
		
		private function decideBlocks(playModeFactor : int) : int
		{
			var blocksBalance : int = 0;
			var blocksAhead : uint = 0;
			var blocksBehind : uint = 0;
			
			for each(var block : Number in m_blocks){
				blocksBalance += block;
				if(block < m_location.x){
					blocksAhead++;
				}
				else{
					blocksBehind++;
				}
			}
			
			/*
			block logic - basic (determined by ret):
			more behind * positive = direction 
			less behind * negative = opposite
			
			block logic - advanced (determined by playMode):
			less behind * positive = direction (DEFENSIVE) or opposite (OFFENSIVE)
			more behind * negative = direction (DEFENSIVE) or opposite (OFFENSIVE)
			*/

			var decisionFactor : int = 0;
			if((blocksBalance < 0 && blocksBehind < blocksAhead) ||
				blocksBalance > 0 && blocksBehind > blocksAhead){
				return blocksBalance;
			}
			else{
				switch(playMode)
				{
					case PlayMode.DEFENSIVE:
						blocksBalance = Math.abs(blocksBalance);
					break;
					case PlayMode.OFFENSIVE:
						if(blocksBalance > 0)	blocksBalance = -blocksBalance;
					break;
				}
				return blocksBalance;
			}
		}
		
		public function doMove(gameObjects : Array, gamePowerups : Array) : void
		{
			m_blocks = new Array();
			m_players = new Array();
			m_powerups = new Array();
			m_location = new Point();
			
			var playModeFactor : uint =  Number(GameManager.dictionary.getParamByName('playModeFactor'));
			
			//update my world view
			UpdateWorldSnapshot(gameObjects, gamePowerups);
			
			var platform : Platform = m_manager.m_platform;
			var currMove : String;
			var isOnEdge : Boolean = false;
			var whichEdge : uint = 0;			
			
			//keep yourself & your blocks away from platform edge
			var rotation : Number = 0;	//will use either m_rotation or m_mostPositiveBlockRotation
			if(m_mostPositiveBlockRotation != 0){
				rotation = m_mostPositiveBlockRotation;
				trace("use block rotation: " + m_mostPositiveBlockRotation + " my rotation: " + m_rotation);
			}
			else{
				rotation = m_rotation;
			}
			
			if(this.distance(platform.x, platform.y) / Number(15 * Number(GameManager.dictionary.getParamByName('worldScale')) - Math.abs(rotation)) > 0.955){
				isOnEdge = true;
				trace("edge");
				
				if(m_location.x / m_direction > 0)	whichEdge = KEY_RIGHT_IDX;
				else								whichEdge = KEY_LEFT_IDX;
			}

			var decision : int = 0;
			var moveDirection : uint = m_directionKey;
			
			decision += decideBlocks(playModeFactor);	//understand block location
			trace("decision: " + decision);
			
			//TODO: decidePowerups
			
			if(decision < 0)
			{
				beStill = false;
				moveDirection = m_oppositeDirectionKey;
			}
			
			//perform move
			currMove = controlsKeys[moveDirection];
			m_manager.preformKeyup(prevMove);
			prevMove = currMove;
			if(!beStill && !(isOnEdge && moveDirection == whichEdge)){
				m_manager.preformKeydown(currMove);
				trace("moving " + moveDirection);
			}
			else{
				trace("not moving");
			}
		}
	}
}

final class PlayMode
{
    public static const DEFENSIVE:uint = 0;
    public static const OFFENSIVE:uint = 1;
}