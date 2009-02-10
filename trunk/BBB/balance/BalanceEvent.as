package balance
{
	import flash.events.Event;

	public class BalanceEvent extends Event
	{
		public static const SET_POWERUP : String = "set_powerup"
		public static const SET_SCORE : String = "set_score"
		
		public var player : String;
		public var powerup : String;
		public var team : int;
		public var score : Number;
		
		public function BalanceEvent(type:String, p_player : String, p_team : int, p_powerup : String, p_score : Number, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			player = p_player;
			powerup = p_powerup;
			team = p_team;
			score = p_score
			super(type, bubbles, cancelable);
		}
	}
}