package com.rightster.utils {
	import flash.external.ExternalInterface;
	/**
	 * @author Arun
	 */
	public class Environment {
		private static const PAGE_DATA_LIMIT : Number = 512;
		
		private var _title : String = "";
		private var _url : String = "";
		private var _referrer : String = "";
		
		public function get title() : String {
			if (ExternalInterface.available) {
				try {
					_title = String(ExternalInterface.call("function () {return document.title;}"));
				}
				catch (err : Error) {
					Log.write("Environment * Error in accessing page title", Log.ERROR);
				}
			}
			return _title;
		}
		
		public function get url() : String {
			if (ExternalInterface.available) {
				try {
					_url = String(ExternalInterface.call("function () {return window.top.location.href;}")).substr(0, PAGE_DATA_LIMIT);
					if (_url == "undefined") {
						_url = "";
					}
				}
				catch (err : Error) {
					Log.write("Environment * Error in accessing page url", Log.ERROR);
				}
			}
			return _url;
		}
		
		public function get referrer() : String {
			if (ExternalInterface.available) {				
				try {
					_referrer = String(ExternalInterface.call("function () {return document.referrer;}")).substr(0, PAGE_DATA_LIMIT);
					if (_referrer == "undefined") {
						_referrer = "";
					}
				}
				catch (err : Error) {
					Log.write("Environment * Error in accessing referrer", Log.ERROR);
				}
			}
			return _referrer;
		}		
	}
}
