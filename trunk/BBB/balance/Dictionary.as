package balance
{
	import flash.events.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class Dictionary
	{
		private var arrParams : Array = new Array();
		public var loader  : URLLoader = null;
		
		public function Dictionary(xmlURL : String)
		{
			// Load the file
			var request : URLRequest = new URLRequest(xmlURL);
			request.contentType = 'text/xml';
			loader = new URLLoader(request);
			
			loader.addEventListener(Event.COMPLETE, loadCompleteHandler);			
		}
		
		private function loadCompleteHandler(e:Event):void {
			var tmpLoader : URLLoader =  URLLoader(e.target);
			var data : XML = new XML(tmpLoader.data); 
			
			for (var paramIdx : int = 0; data.param[paramIdx] != null; paramIdx++) {
				arrParams[data.param[paramIdx].name] = data.param[paramIdx].value;
			}
		}
		
		public function getParamByName(paramName : String) : String {
			if (arrParams[paramName] != null)
			{
				return arrParams[paramName];
			}
			
			return null;
		}
	}
}