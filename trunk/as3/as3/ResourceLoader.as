package as3{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.media.Sound;
	import flash.media.SoundChannel;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	public class ResourceLoader{
		public static function loadXMLData(p_filePath:String):AsyncVar{
			var async:AsyncVar = new AsyncVar();
			var urlloader :URLLoader = new URLLoader();
			var urlRequest :URLRequest = new URLRequest(p_filePath);
			urlloader.addEventListener(Event.COMPLETE,_complete);
			urlloader.load(urlRequest);
			function _complete(e:Event):void{
				async.data = XML(e.currentTarget.data);
				urlloader.removeEventListener(Event.COMPLETE,_complete);
			}
			return async;
		}
		
		public static function loadSFWData(p_filePath:String):AsyncVar{
			var async:AsyncVar = new AsyncVar();
			var urlloader :Loader = new Loader();
			var urlRequest :URLRequest = new URLRequest(p_filePath);
			urlloader.contentLoaderInfo.addEventListener(Event.COMPLETE,_complete);
			urlloader.load(urlRequest);
			function _complete(e:Event):void{
				async.data = e.currentTarget;
				urlloader.contentLoaderInfo.removeEventListener(Event.COMPLETE,_complete);
			}
			return async;
		}
		public static function loadSndData(p_filePath:String):AsyncVar{
			var async:AsyncVar = new AsyncVar();
			var snd :Sound = new Sound();
			var urlRequest :URLRequest = new URLRequest(p_filePath);
			snd.addEventListener(Event.COMPLETE,_complete);
			snd.load(urlRequest);
			function _complete(e:Event):void{
				async.data = snd;
				snd.removeEventListener(Event.COMPLETE,_complete);
			}
			return async;
		}
	}
	
	
}