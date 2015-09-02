package com.rightster.analytics {
	import flash.errors.IllegalOperationError;
	import flash.utils.Dictionary;

	import com.rightster.player.Version;
	import com.rightster.player.events.GenericTrackerEvent;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.model.MetaStream;
	import com.rightster.utils.AssetLoader;
	import com.hurlant.util.Base64;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;

	import flash.events.Event;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * @author KJR
	 */
	public class TwoGATracker extends MovieClip implements IPlugin {
		private static const Z_INDEX : int = PluginZindex.NONE;
		private static const DEFAULT_TRACKING_SERVICE_ENDPOINT : String = "\/\/reportinglogger.my.rightster.com\/stats\/v1\/ping";
		private static const SERVICE_METHOD_VIEW : String = "cv";
		private static const SERVICE_METHOD_PLAY : String = "cp";
		private static const SERVICE_METHOD_PING : String = "pt";
		private static const SERVICE_METHOD_ACTION : String = "ca";
		private static const TIMER_DURATION : uint = 1000;
		private var controller : IController;
		private var _initialized : Boolean;
		private var request : URLRequest;
		private var _loaded : Boolean = true;
		private var adStatus : int;
		private var timer : Timer;
		private var currentSecs : uint;
		private var endPointUrl : String;
		private var pingInterval : int;
		private var pingRegistry : Dictionary;

		public function TwoGATracker() {
			Log.write("TwoGATracker version " + Version.VERSION);
		}

		/*
		 * PUBLIC METHODS
		 */
		public function initialize(controller : IController, data : Object) : void {
			Log.write("TwoGATracker.initialize");
			if (!initialized) {
				this.controller = controller;

				if (data.hasOwnProperty('pingInterval')) {
					pingInterval = data['pingInterval'];
				}

				if (data.hasOwnProperty('endpoint')) {
					Log.write("Using parameterized endpoint");
					endPointUrl = controller.currentProtocol + ':' + data['endpoint'];
				} else {
					Log.write("Using default endpoint");
					endPointUrl = controller.currentProtocol + ':' + DEFAULT_TRACKING_SERVICE_ENDPOINT;
				}

				controller.addEventListener(PlayerStateEvent.CHANGE, handlePlayerStateChangeEvent);
				controller.addEventListener(MonetizationEvent.AD_STARTED, monetizationEventHandler);
				controller.addEventListener(MonetizationEvent.AD_ENDED, monetizationEventHandler);
				controller.addEventListener(GenericTrackerEvent.TRACK, trackSocialClicks);

				adStatus = 0;
				pingRegistry = new Dictionary();
				_initialized = true;
			}
		}

		public function run(data : Object) : void {
			Log.write("TwoGATracker.run * data:" + data);

			if (!initialized) {
				Log.write("TwoGATracker.IllegalOperationError");
				throw new IllegalOperationError();
			}

			// ensure closed
			close();

			if (data.hasOwnProperty('pingInterval')) {
				pingInterval = data['pingInterval'];
			}

			if (data.hasOwnProperty('endpoint')) {
				Log.write("Using parameterized endpoint");
				endPointUrl = controller.currentProtocol + ':' + data['endpoint'];
			} else {
				Log.write("Using default endpoint");
				endPointUrl = controller.currentProtocol + ':' + DEFAULT_TRACKING_SERVICE_ENDPOINT;
			}
			adStatus = 0;
		}

		public function close() : void {
			Log.write("TwoGATracker.close");
			if (!initialized) {
				Log.write("TwoGATracker.IllegalOperationError");
				throw new IllegalOperationError();
			}

			if (timer && timer.running) {
				timer.stop();
				timer.reset();
			}

			clearPings();
		}

		public function dispose() : void {
			Log.write("TwoGATracker.dispose");
			if (initialized) {
				if (timer != null) {
					if (timer.running) {
						timer.stop();
					}

					if (timer.hasEventListener(TimerEvent.TIMER)) {
						timer.removeEventListener(TimerEvent.TIMER, handleTimerEvent);
					}
				}

				clearPings();
				pingRegistry = null;

				controller.removeEventListener(PlayerStateEvent.CHANGE, handlePlayerStateChangeEvent);
				controller.removeEventListener(MonetizationEvent.AD_STARTED, monetizationEventHandler);
				controller.removeEventListener(MonetizationEvent.AD_ENDED, monetizationEventHandler);
				controller.removeEventListener(GenericTrackerEvent.TRACK, trackSocialClicks);

				timer = null;
				controller = null;
				_initialized = false;
			}
		}

		/*
		 * GETTERS/SETTERS
		 */
		public function get zIndex() : int {
			return Z_INDEX;
		}

		public function get loaded() : Boolean {
			return _loaded;
		}

		public function get initialized() : Boolean {
			return _initialized;
		}

		/*
		 * EVENT HANDLERS
		 */
		private function handlePlayerStateChangeEvent(event : PlayerStateEvent) : void {
			switch(controller.playerState) {
				case PlayerState.PLAYER_READY :
					if (controller.placement.showPlaylist) {
						trackPlaylistView();
					}
					break;
				case PlayerState.VIDEO_READY :
					trackEvent(SERVICE_METHOD_VIEW);
					break;
				case PlayerState.VIDEO_STARTED :
					clearPings();
					trackEvent(SERVICE_METHOD_PLAY);
					if (pingInterval) {
						if (!timer ) {
							timer = new Timer(TIMER_DURATION);
							timer.addEventListener(TimerEvent.TIMER, handleTimerEvent);
						}

						timer.start();
					}
					break;
				case PlayerState.VIDEO_PAUSED:
					if (timer && timer.running) {
						timer.stop();
					}
					break;
				case PlayerState.VIDEO_PLAYING:
					if (timer && !timer.running) {
						timer.start();
					}
					break;
				case PlayerState.VIDEO_ENDED:
					if (timer && timer.running) {
						timer.stop();
						timer.reset();
						clearPings();
					}
					break;
			}
		}

		private function monetizationEventHandler(event : MonetizationEvent) : void {
			// Log.write("TwoGATracker.monetizationEventHandler");
			if (event.type == MonetizationEvent.AD_STARTED) {
				adStatus = 2;
			} else if (controller.video.monetization == true && adStatus != 2) {
				adStatus = 1;
			}
		}

		private function successHandler(responseXML : XML) : void {
			// Log.write("TwoGATracker.successHandler", Log.NET);
		}

		/*
		 * PRIVATE METHODS
		 */
		private function handleTimerEvent(event : Event) : void {
			if (controller.playerState == PlayerState.VIDEO_PLAYING) {
				currentSecs = Math.floor(controller.getCurrentTime());

				if ( currentSecs % pingInterval == 0) {
					if (!isRegisteredPing(currentSecs)) {
						registerPing(currentSecs);
						trackEvent(SERVICE_METHOD_PING);
					}
				}
			}
		}

		private function trackPlaylistView() : void {
			// Log.write("TwoGATracker.trackPlaylistView NOT Implemented");
			var variables : String = "?rand=" + Math.random();
			variables += "&uuid=" + controller.placement.userId;
			variables += "&sid=" + controller.placement.userSession;
			variables += "&auth=" + controller.placement.authValue;
			variables += "&fn=" + SERVICE_METHOD_VIEW;
			variables += "&loc=" + Base64.encode(controller.placement.href);
			var now : Date = new Date();
			var epoch : Number = Date.UTC(now.fullYear, now.month, now.date, now.hours, now.minutes, now.seconds, now.milliseconds);
			variables += "&t=" + epoch;
			request = new URLRequest(DEFAULT_TRACKING_SERVICE_ENDPOINT + controller.placement.initialId);
			request.url += variables;
			// controller.loader.load(request, AssetLoader.TYPE_XML, null, false, ErrorCode.PLUGIN_CUSTOM_ERROR, "TwoGATracker.trackPlaylistView * ", successHandler);
		}

		private function trackEvent(serviceMethod : String, vars : Object = null) : void {
			Log.write("TwoGATracker.trackEvent * serviceMethod: " + serviceMethod, Log.TRACKING);
			try {
				var str : String, strUrl : String, bitrate : uint;
				var variables : String = getInitialVariablesAsString();
				var playbackQuality : String = controller.video.playbackQuality || controller.placement.defaultQuality;
				var quality : String = ( controller.video.metaStreams [playbackQuality] as MetaStream).quality;

				if (isNaN(Number(quality))) {
					// use MetaStream bitrate if not a numerical quality (e.g. standardHDS)
					bitrate = (controller.video.metaStreams[playbackQuality] as MetaStream).bitrate;
				} else {
					// use MetaStream quality if a number
					bitrate = Number((controller.video.metaStreams[playbackQuality] as MetaStream).quality);
				}

				switch(serviceMethod) {
					case SERVICE_METHOD_VIEW :
						variables += "&fn=" + SERVICE_METHOD_VIEW;
						str = Base64.encode(controller.placement.href);
						// encode and escape
						variables += "&loc=" + escape(str);
						variables += "&t=" + getTimeStamp();
						variables += "&lm=" + getLogMode();
						variables += "&pid=" + controller.placement.initialId;
						variables += "&vid=" + controller.video.videoId;
						variables += "&v=" + controller.version;
						variables += "&fs=" + formatBooleanForOutput(controller.fullScreen);
						variables += "&ap=" + formatBooleanForOutput(controller.placement.autoPlay);
						variables += "&w=" + controller.width;
						variables += "&h=" + controller.height;
						variables += "&br=" + bitrate;
						variables += "&dur=" + controller.video.durationStr;
						variables += "&q=" + controller.getPlaybackQuality();
						variables += "&pt=" + controller.config.PLAYER_TYPE;
						break;
					case SERVICE_METHOD_PLAY :
						variables += "&fn=" + SERVICE_METHOD_PLAY;
						// encode and escape
						str = Base64.encode(controller.placement.href);
						variables += "&loc=" + escape(str);
						variables += "&as=" + adStatus;
						variables += "&pid=" + controller.placement.initialId;
						variables += "&vid=" + controller.video.videoId;
						variables += "&v=" + controller.version;
						variables += "&fs=" + formatBooleanForOutput(controller.fullScreen);
						variables += "&ap=" + formatBooleanForOutput(controller.placement.autoPlay);
						variables += "&w=" + controller.width;
						variables += "&h=" + controller.height;
						variables += "&br=" + bitrate;
						variables += "&pt=" + controller.config.PLAYER_TYPE;
						break;
					case SERVICE_METHOD_PING:
						variables += "&fn=" + SERVICE_METHOD_PING;
						variables += "&evt=" + currentSecs;
						variables += "&q=" + controller.getPlaybackQuality();
						variables += "&pid=" + controller.placement.initialId;
						variables += "&vid=" + controller.video.videoId;
						variables += "&v=" + controller.version;
						variables += "&fs=" + formatBooleanForOutput(controller.fullScreen);
						variables += "&ap=" + formatBooleanForOutput(controller.placement.autoPlay);
						variables += "&w=" + controller.width;
						variables += "&h=" + controller.height;
						variables += "&br=" + bitrate;
						variables += "&pt=" + controller.config.PLAYER_TYPE;
						break;
					case SERVICE_METHOD_ACTION:
						variables += "&fn=" + SERVICE_METHOD_ACTION;
						variables += "&pid=" + controller.placement.initialId;
						variables += "&as=" + adStatus;
						variables += "&auth=" + controller.placement.authValue;
						variables += "&vid=" + controller.video.videoId;
						// encode and escape
						str = Base64.encode(controller.placement.href);
						variables += "&loc=" + escape(str);
						variables += "&a=click";
						variables += "&d=" + vars['destination'];
						variables += "&v=" + controller.version;
						variables += "&pt=" + controller.config.PLAYER_TYPE;
						break;
				}

				// url encod eth variables
				strUrl = endPointUrl + variables;
				request = new URLRequest(strUrl);
				Log.write("TwoGATracker.trackEvent * url: ", request.url, Log.TRACKING);
				controller.loader.load(request, AssetLoader.TYPE_XML, null, false, ErrorCode.PLUGIN_CUSTOM_ERROR, "TwoGATracker.trackEvent * ", successHandler);
			} catch(error : Error) {
				Log.write(error.toString(), Log.ERROR);
			}
		}

		private function trackSocialClicks(event : GenericTrackerEvent) : void {
			Log.write("TwoGATracker.trackSocialClicks * event: " + event.toString());
			var str : String = event.customAction;
			str = str.substr(0, str.length - 1);
			trackEvent(SERVICE_METHOD_ACTION, {destination:str});
		}

		private function getInitialVariablesAsString() : String {
			var str : String = "?rand=" + Math.random();
			var tmp : String;

			str += "&uuid=" + controller.placement.userId || "";
			str += "&sid=" + controller.placement.userSession || "";

			str += "&cdn=" + (controller.video.metaStreams[controller.getPlaybackQuality()] as MetaStream).cdn || "";
			str += "&st=" + controller.video.eventType || "";

			// encode and escape
			tmp = Base64.encode((controller.video.metaStreams[controller.getPlaybackQuality()] as MetaStream).uri);
			str += "&fp=" + escape(tmp);

			return str;
		}

		private function getTimeStamp() : Number {
			var now : Date = new Date();
			var epoch : Number = Date.UTC(now.fullYear, now.month, now.date, now.hours, now.minutes, now.seconds, now.milliseconds);
			return epoch;
		}

		private function getLogMode() : String {
			return "r";
		}

		private function formatBooleanForOutput(value : Boolean) : String {
			return value ? "1" : "0";
		}

		private function registerPing(pingSecs : uint) : void {
			if (!pingRegistry.hasOwnProperty(pingSecs)) {
				pingRegistry[pingSecs] = true;
			}
		}

		private function isRegisteredPing(pingSecs : uint) : Boolean {
			return ( pingRegistry.hasOwnProperty(pingSecs) && pingRegistry[pingSecs] == true) ? true : false;
		}

		private function clearPings() : void {
			for (var key : String in pingRegistry) {
				pingRegistry[key] = null;
				delete pingRegistry[key];
			}
		}
	}
}
