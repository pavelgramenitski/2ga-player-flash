package com.rightster.player.model {

	public class ErrorCode {
		
		// core errors
		public static const INITIALIZATION_ERROR : String = "1000";
		
		public static const INTEGRITY_ERROR : String = "1001";
		
		// embed errors
		public static const JS_API_UNAVAILABLE : String = "1100";
		
		public static const SHARED_OBJECT_UNAVAILABLE : String = "1101";
		
		public static const FULLSCREEN_UNAVAILABLE : String = "1102";
		
		// loading errors
		public static const ASSET_LOADING_ERROR : String = "1200";
		
		public static const XML_PARSING_ERROR : String = "1201";
		
		public static const MEDIA_URLS_EMPTY : String = "1202";
		
		// content errors
		public static const CONTENT_UNAVAILABLE : String = "1300";
		
		public static const CONTENT_GEOBLOCKED : String = "1301";
		
		public static const MEDIA_ERROR : String = "1302";
		
		// plugin errors
		public static const PLUGIN_INTEGRITY_ERROR : String = "1400";
		
		public static const PLUGIN_CUSTOM_ERROR : String = "1401";
		
	}
}