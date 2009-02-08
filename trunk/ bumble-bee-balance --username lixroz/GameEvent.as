package{
	import flash.events.Event;

	public class GameEvent extends Event{
		public static const RED_TEAM_WIN :String = "RED_TEAM_WIN";
		public static const BLUE_TEAM_WIN :String = "BLUE_TEAM_WIN";
		public static const GAME_OVER :String = "GAME_OVER";
		public static const START_GAME :String = "START_GAME";
		private var m_data:*;
		public function GameEvent(type:String,p_data:*, bubbles:Boolean=false, cancelable:Boolean=false){
			m_data = p_data;
			super(type, bubbles, cancelable);
		}
		
		public function get data():*{
			return m_data
		}
	}
}