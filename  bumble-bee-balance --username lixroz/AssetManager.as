package as3.AssetManager{
	import as3.AsyncVar;
	import as3.ResourceLoader;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	public class AssetManager extends EventDispatcher{
		private static var instance:AssetManager;
	   	private static var m_fileArr:Array;
		public static function getInstance():AssetManager {
         if (instance == null) {
            instance = new AssetManager(new SingletonBlocker());
            m_fileArr = new Array();
          }
         return instance;
       }

		public function AssetManager(p_key:SingletonBlocker):void {
         // this shouldn't be necessary unless they fake out the compiler:
         if (p_key == null) {
            throw new Error("Error: Instantiation failed: Use AssetManager.getInstance() instead of new.");
          }
       }

		
		
		public function getAssetByName(assetName:String):MovieClip{
			if (m_fileArr){
				var cls :Class = m_fileArr[0].applicationDomain.getDefinition(assetName) as Class
				var mc:MovieClip = new cls() as MovieClip
				return mc;
			}
			else{
				return new MovieClip();
			}
		}
		public function addFile(file:Loader):void{
			m_fileArr.push(file.contentLoaderInfo);
		}
		
	}
}
internal class SingletonBlocker {}