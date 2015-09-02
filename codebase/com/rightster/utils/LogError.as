package com.rightster.utils {
	import flash.events.ErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.events.HTTPStatusEvent;
	import flash.net.URLRequestMethod;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.URLRequest;
	import flash.net.URLVariables;
	import flash.net.URLLoader;
	/**
	 * @author Ravi Thapa
	 */
	public class LogError {
		
		private static var URL		: String = "http://playermonitor.rightster.com/index.php";
		
		public static function log(vars : URLVariables) :void{
			var urlLoader : URLLoader = new URLLoader();
			
			var urlReq:URLRequest = new URLRequest(URL);
		    urlReq.method = URLRequestMethod.POST;
			urlReq.data = vars;
			
			urlLoader.addEventListener(Event.COMPLETE, loadComplete);
			urlLoader.addEventListener(IOErrorEvent.IO_ERROR, loadError);
			urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, loadError);
				
			try {
				urlLoader.load(urlReq);
			}
			catch(e : Error) {
				Log.write("LogError.log * cannot connect to url : " + URL + ", error : " + e.message);
			}
		}
		
		private static function loadComplete(evt : Event) : void {
			Log.write(evt.type +"  evt type");
		}
		
		private static function loadError(evt : ErrorEvent) : void {
			Log.write("LogError.Error : " + evt.text);
		}
	}
}