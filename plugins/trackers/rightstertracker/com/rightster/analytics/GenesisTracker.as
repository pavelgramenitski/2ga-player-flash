package com.rightster.analytics {
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
	 * @author Arun
	 */
	public class GenesisTracker extends MovieClip implements IPlugin {
		private static const VERSION : String = "2.28.0";
		private static const Z_INDEX : int = PluginZindex.NONE;
		private static const TRACKING_SERVICE_URL : String = "http://vds_dyn.rightster.com/v/";
		private static const SERVICE_METHOD_VIEW : String = "count_view";
		private static const SERVICE_METHOD_PLAY : String = "count_play";
		private static const SERVICE_METHOD_PING : String = "ping_track";
		private static const SERVICE_METHOD_ACTION : String = "count_action";
		private static const TIMER_DURATION : uint = 1000;
		private var controller : IController;
		private var _initialized : Boolean;
		private var request : URLRequest;
		private var _loaded : Boolean = true;
		private var adStatus : int;
		private var timer : Timer;
		private var secondCounter : uint;

		public function GenesisTracker() {
			Log.write("GenesisTracker version " + VERSION);
		}

		public function get zIndex() : int {
			return Z_INDEX;
		}

		public function get loaded() : Boolean {
			return _loaded;
		}

		public function get initialized() : Boolean {
			return _initialized;
		}

		public function initialize(controller : IController, data : Object) : void {
			Log.write("GenesisTracker.initialize");

			this.controller = controller;
			_initialized = true;

			controller.addEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
			controller.addEventListener(MonetizationEvent.AD_STARTED, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_ENDED, monetizationEventHandler);
			controller.addEventListener(GenericTrackerEvent.TRACK, trackSocialClicks);

			adStatus = 0;
		}

		public function run(data : Object) : void {
			//placeholder
		}

		public function close() : void {
			//placeholder	
			dispose();
		}

		public function dispose() : void {
			if (initialized) {
				if (timer != null) timer.stop();
				controller.removeEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
				controller.removeEventListener(MonetizationEvent.AD_STARTED, monetizationEventHandler);
				controller.removeEventListener(MonetizationEvent.AD_ENDED, monetizationEventHandler);
				controller.removeEventListener(GenericTrackerEvent.TRACK, trackSocialClicks);
				timer = null;
				controller = null;
				_initialized = false;
			}
		}

		private function onPlayerStateChange(event : PlayerStateEvent) : void {
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
					trackEvent(SERVICE_METHOD_PLAY);
					trackEvent(SERVICE_METHOD_PING);
					if (controller.video.trackingPing) {
						secondCounter = 0;
						timer = new Timer(TIMER_DURATION);
						timer.addEventListener(TimerEvent.TIMER, trackPing);
						timer.start();
					}
					break;
			}
		}

		private function monetizationEventHandler(event : MonetizationEvent) : void {
			if (event.type == MonetizationEvent.AD_STARTED) {
				adStatus = 2;
			} else if (controller.video.monetization == true && adStatus != 2) {
				adStatus = 1;
			}
		}

		private function trackPing(event : Event) : void {
			if (controller.playerState == PlayerState.VIDEO_PLAYING) {
				secondCounter++;
				if (secondCounter == controller.video.trackingInterval) {
					trackEvent(SERVICE_METHOD_PING);
					secondCounter = 0;
				}
			}
		}

		private function trackPlaylistView() : void {
			var variables : String = "?rand=" + Math.random();
			variables += "&uuid=" + controller.placement.userId;
			variables += "&sid=" + controller.placement.userSession;
			variables += "&auth=" + controller.placement.authValue;
			variables += "&fn=" + SERVICE_METHOD_VIEW;
			variables += "&loc=" + Base64.encode(controller.placement.href);
			var now : Date = new Date();
			var epoch : Number = Date.UTC(now.fullYear, now.month, now.date, now.hours, now.minutes, now.seconds, now.milliseconds);
			variables += "&t=" + epoch;
			request = new URLRequest(TRACKING_SERVICE_URL + controller.placement.initialId);
			request.url += variables;

			controller.loader.load(request, AssetLoader.TYPE_XML, null, false, ErrorCode.PLUGIN_CUSTOM_ERROR, "GenesisTracker.trackPlaylistView * ", success);
		}

		private function trackEvent(serviceMethod : String, vars : Object = null) : void {
			var variables : String = "?rand=" + Math.random();
			variables += "&uuid=" + controller.placement.userId;
			variables += "&sid=" + controller.placement.userSession;
			variables += "&auth=" + controller.placement.authValue;

			if (controller.placement.showPlaylist) {
				variables += "&pid=" + controller.placement.initialId;
			}

			variables += "&streamtype=" + controller.video.eventType;
			variables += "&cdn=" + (controller.video.metaStreams[controller.getPlaybackQuality()] as MetaStream).cdn;

			var quality : int = getPlaybackQuality();

			switch(serviceMethod) {
				case SERVICE_METHOD_VIEW :
					variables += "&fn=" + SERVICE_METHOD_VIEW;
					variables += "&loc=" + Base64.encode(controller.placement.href);
					var now : Date = new Date();
					var epoch : Number = Date.UTC(now.fullYear, now.month, now.date, now.hours, now.minutes, now.seconds, now.milliseconds);
					variables += "&t=" + epoch;
					break;
				case SERVICE_METHOD_PLAY :
					variables += "&fn=" + SERVICE_METHOD_PLAY;
					variables += "&cid=" + controller.video.projectId;
					variables += "&pingenabled=" + Number(controller.video.trackingPing);
					variables += "&loc=" + Base64.encode(controller.placement.href);
					variables += "&quality=" + quality;
					variables += "&adstatus=" + adStatus;
					break;
				case SERVICE_METHOD_PING:
					variables += "&fn=" + SERVICE_METHOD_PING;
					variables += "&cid=" + controller.video.projectId;
					variables += "&quality=" + quality;
					variables += "&evtid=" + int(controller.getCurrentTime());
					variables += "&pingduration=" + controller.video.trackingInterval;
					variables += "&bitrate=" + (controller.video.metaStreams[controller.getPlaybackQuality()] as MetaStream).bitrate;
					break;
				case SERVICE_METHOD_ACTION:
					variables += "&fn=" + SERVICE_METHOD_ACTION;
					variables += "&adstatus=" + adStatus;
					variables += "&cid=" + controller.video.projectId;
					variables += "&loc=" + Base64.encode(controller.placement.href);
					variables += "&action=click";
					variables += "&trigger_point=" + controller.getCurrentTime();
					variables += "&destination=" + vars['destination'];
					break;
			}

			request = new URLRequest(TRACKING_SERVICE_URL + controller.video.videoId);
			request.url += variables;

			controller.loader.load(request, AssetLoader.TYPE_XML, null, false, ErrorCode.ASSET_LOADING_ERROR, "GenesisTracker.trackEvent * ", success);
		}

		private function trackSocialClicks(event : GenericTrackerEvent) : void {
			var str : String = event.customAction;
			str = str.substr(0, str.length - 1);
			trackEvent(SERVICE_METHOD_ACTION, {destination:str});
		}

		private function success(responseXML : XML) : void {
			Log.write("GenesisTracker.success * url : " + request.url + ", response : " + responseXML, Log.NET);
		}

		private function getPlaybackQuality() : int {
			for (var i : int = 0; i < controller.video.qualities.length; i++) {
				if (controller.getPlaybackQuality() == controller.video.qualities[i]) {
					break;
				}
			}
			return i + 1;
		}
	}
}
