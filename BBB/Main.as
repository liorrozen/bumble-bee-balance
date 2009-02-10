package {
	import as3.AssetManager.AssetManager;
	import as3.AsyncVar;
	import as3.ResourceLoader;
	
	import balance.Dictionary;
	import balance.GameEvent;
	import balance.GameManager;
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	[SWF(width="800", height="600", frameRate="24", backgroundColor="#FFFFFF")]
	public class Main extends Sprite
	{
		private var m_gameManager :GameManager
		private var m_redScore :uint = 0;
		private var m_blueScore :uint = 0;
		private var m_gui :MovieClip;
		private var playerObj:Object;
		private var m_dict : Dictionary;
		
		private var m_botControllArr :Array;
		
		/*  "m_gameParams" is an array that contains information about each player.
		it is passed as a parameter to the constructor of the gameManager... */
		private var m_gameParams :Array;
		
		private var m_timer:Timer;
		
		public function Main()
		{
			m_botControllArr = 
				new Array(
					["bA","bB","bC","bD"],
					["bE","bF","bG","bH"],
					["bI","bJ","bK","bL"],
					["bM","bN","bO","bP"],
					["bQ","bR","bS","bT"],
					["bU","bV","bW","bX"]);
			
			m_timer = new Timer(100);
			m_timer.addEventListener(TimerEvent.TIMER,gameTickHandler);
			this.stage.align = StageAlign.TOP_LEFT;
			this.stage.scaleMode = StageScaleMode.NO_SCALE;
			m_gameParams = new Array();
			var interfaceAsync:AsyncVar = ResourceLoader.loadSFWData("BBB.swf");
			interfaceAsync.setHandler(_init);
			function _init(e:Loader):void{
				m_gui = e.content as MovieClip
				addChild(m_gui);
				AssetManager.getInstance().addFile(e);
				m_gui.gamePlay_mc.visible = false;
				
				// Load the dictionary
				m_dict = new Dictionary('dict.xml');
				m_dict.loader.addEventListener(Event.COMPLETE, function dictLoaded(e:Event){
				// After the dictionary is loaded a new game can start
				m_gui.openingScreen_mc.start_btn.addEventListener(MouseEvent.CLICK,newGame)
				});
			}
		}
		
		private function newGame(e:Event):void{
			if (verifyForm()){
				m_gui.openingScreen_mc.visible = false;
				m_gui.gamePlay_mc.visible = true;
				m_gameManager = new GameManager(m_gameParams, m_dict);
				m_timer.start()
				m_gui.addChild(m_gameManager);
				m_gameManager.startGame();
				addEventListener(GameEvent.GAME_OVER,_gameOverHandler);
				function _gameOverHandler(e:GameEvent):void{
					if (e.type == GameEvent.RED_TEAM_WIN){
						m_redScore++;
						trace("m_redScore++")
					}
					else{
						if (e.type == GameEvent.BLUE_TEAM_WIN){
								m_blueScore++;
								trace("m_blueScore++;")
						}
						else{
							trace("DRAW!")
						}
					}
					if (m_redScore == 3 || m_blueScore == 3){
						if (m_redScore == 3){
							//show popup red wins ALL
						}
						else{
							if (m_blueScore == 3){
								//show popup blue wins ALL
							}
						}
					}
				}
			}
			else{
				trace("form not verified")
			}
		}
		
		private function verifyForm():Boolean{
			var redPlayers :Array = getChildren(m_gui.openingScreen_mc.redTeam)
			var bluePlayers :Array = getChildren(m_gui.openingScreen_mc.blueTeam);
			if (_verify(redPlayers,2) && _verify(bluePlayers,1)){
					return true; // All teams verified
			}
			function _verify(players:Array,p_team:uint):Boolean{
				var numPlayers:uint = 0;
				for (var i:uint = 0;i< players.length;i++){
					if (players[i].checkBox.selected == true){ 
						numPlayers++;
						if (players[i].comboBox.selectedIndex == 0){//Conditional - No control scheme selected for active player
							return false;
						}
						else{
							if (players[i].comboBox.selectedItem.label != "Computer"){
								var controlArr = new Array(players[i].comboBox.selectedItem.data)
								var paramArr :Array = controlArr[0].split(",");
								m_gameParams.push({name:players[i].nameTxt.text,team:p_team,type:"human",controlls:paramArr})
							}
							else{
								m_gameParams.push(
								{name:"Bot" + i,
								 team:p_team,
								 type:"bot",
								 // Make sure no bot gets the same keys as anothr bot
								 // the lower 3 sets of keys are for team 1 and the upper
								 // 3 are for team 2
								 controlls:m_botControllArr[((p_team - 1) * 3) + i]});
							}
						}
					}
					//TODO Conditional - Duplicate control scheme for team mates
					players[i].comboBox.enabled = false;
				}
				if (numPlayers > 0){
					return true; // Team is verified
				}
				return false; //Team not verified
			}
			return false; //Teams not verified
		}
		
		private function getChildren(parent:DisplayObjectContainer):Array{
			var retArr:Array = new Array();
			var i:int = parent.numChildren;
			while(i--){
  				 var child:DisplayObject = parent.getChildAt(i);
    			 retArr.push(child);
			}
			return retArr
		}
		
		private function gameTickHandler(e:TimerEvent):void{
			var mins :uint = Math.floor(m_timer.currentCount / 60);
			var secs :uint = (m_timer.currentCount < 60)?m_timer.currentCount:m_timer.currentCount-(60*mins)
			if (mins > 0 && secs > 29){
				endofGame();
			}
			else
			{
				if (secs >= 10){
					m_gui.gamePlay_mc.time_txt.text = mins+":"+secs
				}else{
					m_gui.gamePlay_mc.time_txt.text = mins+":"+"0"+secs
				}
			}
		}
		private function endofGame():void{
			m_gameManager.endGame();
			m_timer.stop();
			m_timer.reset();	
		}
	}
}
