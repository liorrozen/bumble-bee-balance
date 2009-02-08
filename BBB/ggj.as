package {
	import as3.AssetManager.AssetManager;
	
	import balance.GameManager;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	[SWF(width=800,height=800)]
	public class ggj extends Sprite
	{
		var tmpLoader : Loader;
		
		public function ggj()
		{
			tmpLoader = new Loader();
			tmpLoader.load(new URLRequest("BBB.swf"));
			
			tmpLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadingDone);
		}
		
		public function loadingDone(e:Event):void {
			AssetManager.getInstance().addFile(tmpLoader); 
			
			var playerDef : Array = new Array()
			playerDef.push({name:"player1",team:"1",type:"human",controlls:["left","right","up","down"]})
			playerDef.push({name:"player2",team:"1",type:"human",controlls:["bF","bH","bT","bG"]})
			playerDef.push({name:"player3",team:"2",type:"human",controlls:["bJ","bL","bI","bK"]})
			playerDef.push({name:"player4",team:"2",type:"human",controlls:["bA","bD","bW","bS"]})
			var game : GameManager = new GameManager(playerDef);
			addChild(game);
		}
	}
}