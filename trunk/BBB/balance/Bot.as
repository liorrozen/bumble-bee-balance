package balance
{
	import Box2D.Common.Math.b2Vec2;
	import Box2D.Dynamics.b2World;
	
	import flash.display.*;

	public class Bot extends Player
	{
		private var prevMove : String = "R";
		public var controlsKeys : Array = null;
		private const KEY_LEFT_IDX : int = 0;
		private const KEY_RIGHT_IDX :int = 1;
		private const KEY_UP_IDX : int = 2;
		private const KEY_DOWN_IDX : int = 3;
		private var beStupid : Boolean = false;
		private var beStill : Boolean = false;
		
		public function Bot(world:b2World, position : b2Vec2,
							manager : GameManager,
							p_team : uint, p_name : String,
							controls : Array)
		{
			controlsKeys = controls;
			super(world, position, manager, p_team, p_name);
		}
		
		public function doMove() : void
		{
			var platform : Platform = m_manager.m_platform;
			var currMove : String;
			
			if (beStill)
			{
				m_manager.preformKeyup(prevMove);
				if (Math.random() < 0.05) beStill = false;
				return;
			}
			
			if (Math.random() < 0.005) {
				beStill = true;
			}
			
			// Be stupid rarely - change you mind about goal 
			if (!beStupid && Math.random() < 0.01)
			{
				beStupid = true;
			}
			
			if (beStupid && Math.random() < 0.01)
			{
				beStupid = false;
			}
			
			
			// The closer you get to the edge the likely to continue you are.
			if (((this.distance(platform.x, platform.y) / 
				((15 * Number(GameManager.dictionary.getParamByName('worldScale'))) / 2))  <
					1.1 + (Math.random() / 2)) ||
				Math.random() < 0.05)
			{
				if(platform.rotation > (0 + (Math.random()/2 - 0.25) * 30))
				{
					currMove =  controlsKeys[KEY_LEFT_IDX];
				}
				else
				{
					currMove = controlsKeys[KEY_RIGHT_IDX];
				}
			}
			
			if (beStupid)
			{
				if (currMove == controlsKeys[KEY_LEFT_IDX])
				{
					currMove = controlsKeys[KEY_RIGHT_IDX];
				}
				else if (currMove == controlsKeys[KEY_RIGHT_IDX])
				{
					currMove = controlsKeys[KEY_LEFT_IDX];
				}
			}
			
			// Random jump here and there
			if (Math.random() < 0.01)
			{
				currMove = controlsKeys[KEY_UP_IDX];
			}
			
			if (prevMove == controlsKeys[KEY_UP_IDX])
			{
				prevMove = currMove;
			}
			
			if (prevMove != currMove && Math.random() < 0.05)
			{
				currMove = controlsKeys[KEY_UP_IDX];
			}
			
			m_manager.preformKeyup(prevMove);
			prevMove = currMove;
			
			m_manager.preformKeydown(currMove);
		}
	}
}