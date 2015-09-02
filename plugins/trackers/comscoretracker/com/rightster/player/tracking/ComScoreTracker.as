package com.rightster.player.tracking {
	import flash.events.AsyncErrorEvent;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;

	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	/**
	 * @author Sidharth
	 */
	public class ComScoreTracker extends MovieClip implements IPlugin {
		private static const VERSION : String = "2.6.0";
		private static const Z_INDEX : int = PluginZindex.NONE;
		private static const TRACKING_URL_STRING_LIMIT : Number = 2080;
		private static const VIDEO_TRACK_STRING: String   = '03';
		private static const PREROLL_TRACK_STRING: String = '09';
		
		private static const HTTP_SERVICE : String = "http://b.scorecardresearch.com/p";
		private static const HTTPS_SERVICE : String = "http://sb.scorecardresearch.com/p";
		private static const BEACON_VERSION : String = "2.0";
		private static const C_COUNT : uint = 10; // : The name of the player the plugin is currently being server from.
		private static const MAPPING_PLAYER_NAME : String = "experience.playerName"; // : The name of the player the plugin is currently being server from.
		private static const MAPPING_URL : String = "experience.url"; // : The current URL of the page. This may not be available if using the HTML embed code.
		private static const MAPPING_PLAYER_ID : String = "experience.id"; // : The ID of the player.
		private static const MAPPING_PUBLISHER : String = "experience.publisherID"; // : The ID of the publisher to which the media item belongs.
		private static const MAPPING_REFERRER : String = "experience.referrerURL"; // : The url of the referrer page where the player is loaded.
		private static const MAPPING_COUNTRY : String = "experience.userCountry"; // : The country the user is coming from.
		private static const MAPPING_AD_KEYS : String = "video.adKeys"; // : Key/value pairs appended to any ad requests during media's playback.
		//private static const MAPPING_CUOTOM : String = "video.customFields"; //['customfieldname'] : Publisher-defined fields for media. 'customfieldname' would be the internal name of the custom field you wish to use.
		private static const MAPPING_DISPLAY : String = "video.displayName"; // : Name of media item in the player.
		private static const MAPPING_ECONOMICS : String = "video.economics"; // : Flag indicating if ads are permitted for this media item.
		private static const MAPPING_VIDEO_ID : String = "video.id"; // : Unique Brightcove ID for the media item.
		private static const MAPPING_LENGTH : String = "video.length"; // : The duration on the media item in milliseconds.
		private static const MAPPING_LINEUP : String = "video.lineupId"; // : The ID of the media collection (ie playlist) in the player containing the media, if any.
		private static const MAPPING_LINK_TEXT : String = "video.linkText"; // : The text for a related link for the media item.
		private static const MAPPING_LINK_URL : String = "video.linkURL"; // : The URL for a related link for the media item.
		private static const MAPPING_LONG_DESC : String = "video.longDescription"; // : Longer text description of the media item.
		private static const MAPPING_SHORT_DESC : String = "video.shortDescription"; // : Short text description of the media item.
		private static const MAPPING_PUBLISHER2 : String = "video.publisherId"; // : The ID of the publisher to which the media item belongs.
		private static const MAPPING_REFERENCE : String = "video.referenceId"; // : Publisher-defined ID for the media item.
		private static const MAPPING_THUMBNAIL : String = "video.thumbnailURL"; // : URL of the thumbnail image for the media item.
		
		private var controller : IController;
		private var data : Object;
		private var initialized	: Boolean;
		private var loader : URLLoader;
		private var url : String;
		private var mapping : XML;
		private var cValues : Array;
		private var isLoadingMap : Boolean = false;
		private var eventBucket : Array;
		
		public function ComScoreTracker() {
			Log.write("ComScoreTracker ver * " + VERSION);
		}
		
		public function initialize(controller : IController, data : Object) : void {
			Log.write("ComScoreTracker.initialize");
			initialized = true;
			this.controller = controller;
			this.data = data;	
			
			controller.addEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
			
			loader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				
			if (controller.placement.comscoreMap != "") {
				isLoadingMap = true;
				eventBucket = [];
				loader.addEventListener(Event.COMPLETE, loadComplete);				
				var request : URLRequest = new URLRequest(controller.placement.comscoreMap);
				
				try {
					Log.write(request.url, Log.NET);
					loader.load(request);
				} catch (err : Error) {
					controller.error(ErrorCode.ASSET_LOADING_ERROR, "ComScoreTracker.loadMappingXML * " + err.message + " * url: " + request.url, false);
				}
			}
		}
		
		public function get zIndex() : int {
			return Z_INDEX;
		}
		
		private function loadComplete(e : Event) : void {
			mapping = new XML(loader.data);
			Log.write(mapping);
			mapValues();
			isLoadingMap = false;
			if (eventBucket.length > 0) {
				for (var i : int = 0; i < eventBucket.length; i++) {
					sendBeacon(eventBucket[i]);
				}
			}
		}
		
		private function onPlayerStateChange(event : Event) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_STARTED :
					if (!isLoadingMap) {
						sendBeacon(VIDEO_TRACK_STRING);				
					}
					else {
						eventBucket.push(VIDEO_TRACK_STRING);
					}
				break;
				
				case PlayerState.AD_STARTED :	
					if (!isLoadingMap) {
						sendBeacon(PREROLL_TRACK_STRING);				
					}
					else {
						eventBucket.push(PREROLL_TRACK_STRING);
					}
				break;
			}
		}
		
		private function mapValues() : void {
			cValues = new Array(C_COUNT);
			
			cValues[7] = controller.placement.embedPageUrl;
			cValues[8] = controller.placement.embedPageTitle;
			cValues[9] = controller.placement.referrer;
			
			for (var i : int = 1; i <= C_COUNT; i++) {
				if (data.hasOwnProperty("c" + i)) cValues[i] == data["c" + i];
			}
			
			for each (var map : XML in mapping.cValues.cValue) {
				switch (String(map.@value)) {
					case MAPPING_PLAYER_NAME :
						cValues[map.@number] = controller.config.PLAYER_NAME;
					break;
					case MAPPING_URL :
						cValues[map.@number] = controller.placement.embedPageUrl;
					break;
					case MAPPING_PLAYER_ID :
						cValues[map.@number] = controller.placement.playerId;
					break;
					case MAPPING_PUBLISHER :
						cValues[map.@number] = controller.placement.publisherId;
					break;
					case MAPPING_REFERRER :
						cValues[map.@number] = controller.placement.referrer;
					break;
					case MAPPING_COUNTRY :
						cValues[map.@number] = "";
					break;
					case MAPPING_AD_KEYS :
						cValues[map.@number] = controller.video.tags;
					break;
					case MAPPING_DISPLAY :
						cValues[map.@number] = controller.video.title;
					break;
					case MAPPING_ECONOMICS :
						cValues[map.@number] = controller.video.fetchVast == true ? 1 : 10;
					break;
					case MAPPING_VIDEO_ID :
						cValues[map.@number] = controller.video.videoId;
					break;
					case MAPPING_LENGTH :
						cValues[map.@number] = controller.video.duration * 1000;
					break;
					case MAPPING_LINEUP :
						cValues[map.@number] = controller.placement.playlistId;
					break;
					case MAPPING_LINK_TEXT :
						cValues[map.@number] = "";
					break;
					case MAPPING_LINK_URL :
						cValues[map.@number] = "";
					break;
					case MAPPING_LONG_DESC :
						cValues[map.@number] = "";
					break;
					case MAPPING_SHORT_DESC :
						cValues[map.@number] = "";
					break;
					case MAPPING_PUBLISHER2 :
						cValues[map.@number] = controller.placement.publisherId;
					break;
					case MAPPING_REFERENCE :
						cValues[map.@number] = "";
					break;
					case MAPPING_THUMBNAIL :
						cValues[map.@number] = controller.video.thumbnailImage;
					break;
				}
			}
		}
		
		private function sendBeacon(action : String) : void {
			url = controller.placement.embedPageUrl.indexOf("https:") == 0 ? HTTP_SERVICE : HTTPS_SERVICE;
			url = url + "?cv=" + BEACON_VERSION;
			url = url + "&rn=" + Math.random();
			url = url + "&c5=" + action;
			
			for (var i : int = 0; i < cValues.length; i++) {
				url = url + "&c" + i + "=" + cValues[i];
			}
			
			if (url.length > TRACKING_URL_STRING_LIMIT) {
				url = url.substr(0,TRACKING_URL_STRING_LIMIT);
			}
			
			try {
				Log.write("ComeScoreTracker.comScoreBeacon * " + url, Log.TRACKING);
				loader.load(new URLRequest(url));
			} catch (err : 	Error) {
				controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "ComeScoreTracker.comScoreBeacon * " + err.message + " * url: " + url);
			}
		}
		
		private function errorHandler(event : Event):void{
			controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "ComeScoreTracker.errorHandler * " + event['text'] + " * url: " + url);
		}
		
		public function dispose() : void {
			if (initialized) {
				controller.removeEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
				controller = null;
				loader.close();
				data = null;
			}			
		}
	}
}