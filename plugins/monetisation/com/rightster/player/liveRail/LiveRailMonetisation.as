package com.rightster.player.liveRail {
	import flash.utils.describeType;
	// import flash.utils.describeType;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.events.VPAIDEvent;
	import com.rightster.player.media.IMonetization;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.LoopMode;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.AssetLoader;
	import com.rightster.utils.Log;
	import com.rightster.utils.VolumeUtils;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.geom.Rectangle;
	import flash.net.URLRequest;
	import flash.system.Capabilities;
	import flash.system.Security;
	import flash.utils.Timer;

	/**
	 * @author Sidharth
	 */
	public class LiveRailMonetisation extends MovieClip implements IMonetization , IPlugin {
		private static const UPDATE_RATE : Number = 1000 / 60;
		// LiveRail Constants TWO GA
		// PREFIXES
		private static const LR_PREFIX_PLAYLIST_POSITION : String = "pos_";
		private static const LR_PREFIX_PLAYER : String = "player_";
		private static const LR_TAGS : String = "LR_TAGS";
		// PLAYBACK
		private static const LR_WIDTH : String = "LR_WIDTH";
		private static const LR_HEIGHT : String = "LR_HEIGHT";
		private static const LR_SDK : String = "LR_SDK";
		private static const LR_USER_AGENT : String = "LR_USER_AGENT";
		private static const LR_MUTED : String = "LR_MUTED";
		private static const LR_AUTOPLAY : String = "LR_AUTOPLAY";
		private static const LR_URL : String = "LR_URL";
		private static const LR_VIDEO_DURATION : String = "LR_VIDEO_DURATION";
		private static const LR_PLAYER_WIDTH : String = "LR_PLAYER_WIDTH";
		private static const LR_PLAYER_HEIGHT : String = "LR_PLAYER_HEIGHT";
		// PAGEPLAYER
		private static const LR_PREFIX_PAGEPLAYER : String = "pp_";
		private static const LR_PREFIX_LISTSTYLE : String = "ls_";
		private static const LR_PREFIX_DISPLAYSTYLE : String = "ds_";
		// LEGACY 1GA
		// private static const LR_VERSION : String = "LR_VERSION";
		// private static const LR_ADMAP : String = "LR_ADMAP";
		private static const LR_PLAYERSIZE : String = "LR_PLAYERSIZE";
		// private static const LR_LAYOUT_SKIN_ID : String = "LR_LAYOUT_SKIN_ID";
		// private static const LR_LAYOUT_OVERLAY_YOFFSET : String = "LR_LAYOUT_OVERLAY_YOFFSET";
		//
		// private static const PLAYERSIZE_SMALL : String = "Small";
		// private static const PLAYERSIZE_MEDIUM : String = "Medium";
		// private static const PLAYERSIZE_LARGE : String = "Large";
		private static const PLAYERSIZE_UNKNOWN : uint = 0;
		private static const PLAYERSIZE_SMALL : uint = 1;
		private static const PLAYERSIZE_MEDIUM : uint = 2;
		private static const PLAYERSIZE_LARGE : uint = 3;
		private static const MIN_PLAYER_WIDTH : uint = 300;
		private static const MIN_PLAYER_HEIGHT : uint = 250;
		private static const MAX_PLAYER_WIDTH : uint = 480;
		private static const MAX_PLAYER_HEIGHT : uint = 320;
		private static const VERSION : String = "2.28.12";
		private static const Z_INDEX : int = PluginZindex.BELOW_CHROME;
		private static const AD_MANAGER_Z_INDEX : int = 0;
		private static const AD_MANAGER_DOMAIN : String = 'vox-static.liverail.com';
		private static const AD_MANAGER_DOMAIN_SECURE : String = 'cdn-static-secure.liverail.com';
		private static const AD_MANAGER_URL : String = 'http://vox-static.liverail.com/swf/v4/admanager.swf';
		private static const AD_MANAGER_URL_SECURE : String = 'https://cdn-static-secure.liverail.com/swf/v4/admanager.swf';
		// private static const AD_MANAGER_VERSION : String = "4.1";
		private static const AD_MANAGER_SCALE : Number = 1;
		// private static const LAYOUT_SKIN_ID : String = '1';
		// private static const LAYOUT_OVERLAY_YOFFSET : String = '-20';
		// private static const COUNTDOWN_MESSAGE : String = 'Your video will start in {COUNTDOWN} sec';
		// private static const COUNTDOWN_PLACEHOLDER : String = '{COUNTDOWN}';
		private static const INIT_COMPLETE : String = "initComplete";
		private static const INIT_ERROR : String = "initError";
		private static const PREROLL_COMPLETE : String = "prerollComplete";
		// private static const AD_START : String = "adStart";
		private static const AD_END : String = "adEnd";
		private static const AD_PROGRESS : String = "adProgress";
		private static const AD_CLICKTHRU : String = "clickThru";
		// private static const AD_LOADED_EVENT : String = "AdLoaded";
		private static const QC_API_URL : String = "http://pixel.quantserve.com/api/segments.xml?a=";
		private static const QC_SEGMENT_ID : String = "15437";
		private static const QC_WAITING_TIME : uint = 30000;
		private static const OVER_LAY_AD_TIME : uint = 1000;
		private static const OVER_LAY_AD_START : String = "overlayAdStart";
		private static const OVER_LAY_AD_END : String = "overlayAdEnd";
		private static const OVER_LAY_AD_MINIMIZE : String = "overlayAdMinimize";
		private static const OVER_LAY_AD_MAXMIZE : String = "overlayAdMaximize";
		private static const VPAID_VERSION : String = "2.0";
		private var controller : IController;
		private var adManager : Object;
		private var qcLRVerticalValue : String;
		private var timer : Timer;
		private var adManagerRenderedWithSuccess : Boolean;
		private var request : URLRequest;
		private var forceAdBreak : Boolean;
		private var _currentTime : Number = 0;
		private var _duration : Number = 0;
		private var _loaded : Boolean = true;
		private var configParams : Object;
		private var _initialized : Boolean;

		// private var adDidNotifyCompletion : Boolean = false;
		public function LiveRailMonetisation() {
			Log.write("LiveRailMonetisation * v" + VERSION);
		}

		/*
		 * PUBLIC METHODS
		 */
		public function initialize(controller : IController, data : Object) : void {
			Log.write("LiveRailMonetisation.initialize");
			if (!initialized) {
				this.controller = controller;
				configParams = data;
				controller.addEventListener(ResizeEvent.RESIZE, resize);
				controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
				controller.addEventListener(MonetizationEvent.AD_STOP, stopAds);
				adManagerRenderedWithSuccess = false;
				forceAdBreak = false;
				initQuantCast();
				_initialized = true;
			}
		}

		public function run(data : Object) : void {
			Log.write("LiveRailMonetisation.run");
			if (!initialized) {
				Log.write("LiveRailMonetisation.IllegalOperationError");
				throw new IllegalOperationError();
			}
			configParams = data;
			adManagerRenderedWithSuccess = false;
			forceAdBreak = false;
		}

		public function close() : void {
			Log.write("LiveRailMonetisation.close");
			if (!initialized) {
				Log.write("LiveRailMonetisation.IllegalOperationError");
				throw new IllegalOperationError();
			}

			if (timer) {
				timer.stop();
			}

			if (adManager && adManagerRenderedWithSuccess) {
				adManager.stopAd();
			}
		}

		public function dispose() : void {
			Log.write("LiveRailMonetisation.dispose");

			if (_initialized) {
				disposeAdManager();

				if (timer != null) {
					timer.removeEventListener(TimerEvent.TIMER, onTimer);
					timer.stop();
					timer = null;
				}

				controller.removeEventListener(ResizeEvent.RESIZE, resize);
				controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
				controller.removeEventListener(MonetizationEvent.AD_STOP, stopAds);
				controller = null;

				_initialized = false;
			}
		}

		public function playVideo() : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.VIDEO_CUED :
					// TODO : dirty hack for playing one preroll ad in timed piped playlist
					if (controller.placement.playlistVersion != 2 || (controller.placement.playlistVersion == 2 && controller.getPlaylistIndex() == 0)) {
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_REQUESTED));
						loadAdManager();
					} else {
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
					}
					break;
				case PlayerState.AD_PAUSED :
					if (adManager) {
						adManager.resumeAd();
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
					}
					break;
				case PlayerState.VIDEO_PAUSED :
					if (controller.placement.playlistVersion == 2 || controller.placement.livePlaylist) {
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_REQUESTED));
						forceAdBreak = true;
						loadAdManager();
					}
					break;
			}
		}

		public function pauseVideo() : void {
			if (adManager && controller.playerState == PlayerState.AD_PLAYING) {
				adManager.pauseAd();
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PAUSED));
			}
		}

		public function stopVideo() : void {
			if (adManager) {
				adManager.stopAd();
				// adDidNotifyCompletion = true;
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
			}
		}

		public function seekTo(seconds : Number, allowSeekAhead : Boolean) : void {
		}

		public function getCurrentTime() : Number {
			return 0;
		}

		public function getDuration() : Number {
			return 0;
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

		public function set volume(n : Number) : void {
			if (adManager) {
				adManager.setVolume(VolumeUtils.formatToCodeLevel(n), controller.isMuted());
			}
		}

		public function set muted(b : Boolean) : void {
			if (adManager) {
				adManager.setVolume(VolumeUtils.formatToCodeLevel(controller.getVolume()), controller.isMuted());
			}
		}

		/*
		 * EVENT HANDLERS
		 */
		private function onLiveRailInitComplete(event : Event) : void {
			Log.write("LiveRailMonetisation.onLiveRailInitComplete * event:" + event.toString());
			resize();

			// Log.write("controller.flashVars.startmutedx: " + controller.flashVars.startmuted);

			adManager.setVolume(VolumeUtils.formatToCodeLevel(controller.getVolume()), controller.isMuted());

			adManager.onContentStart();

			timer = new Timer(OVER_LAY_AD_TIME);
			timer.addEventListener(TimerEvent.TIMER, onTimer);
		}

		private function onLiveRailLoadError() : void {
			Log.write("LiveRailMonetisation.onLiveRailLoadError", Log.ERROR);
			// TODO: KJR check requirement for error handling here - was commented out
			// controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "LiveRailMonetisation.onLiveRailLoadError * " + event['text'] + " * url: " + AD_MANAGER_URL);
			// adDidNotifyCompletion = true;
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
		}

		private function onLiveRailInitError(event : Event) : void {
			controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "LiveRailMonetisation.onLiveRailInitError * " + event.toString() + " * url: " + AD_MANAGER_URL);
			// adDidNotifyCompletion = true;
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
		}

		private function onTimerComplete(event : TimerEvent) : void {
			Log.write("LiveRailMonetisation.onTimerComplete");
			errorHandler();
		}

		private function errorHandler() : void {
			Log.write("LiveRailMonetisation.errorHandler");
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				timer = null;
			}

			qcLRVerticalValue = "";

			if (adManagerRenderedWithSuccess) {
				initLiveRail();
			}
		}

		private function onQcloadComplete(result : XML) : void {
			Log.write("LiveRailMonetisation.onQcloadComplete * " + result);
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
				timer = null;
			}

			try {
				filterQuantCastID(result);
			} catch (error : Error) {
				controller.error(ErrorCode.XML_PARSING_ERROR, "LiveRailMonetisation.onQcloadComplete * " + error.message + " * QC_API_URL: " + QC_API_URL + " * QUANT_CAST_ID :- " + controller.placement.pcodeValue);
			}

			if (adManagerRenderedWithSuccess) {
				initLiveRail();
			}
		}

		private function resize(event : ResizeEvent = null) : void {
			Log.write("LiveRailMonetisation.resize");
			if (adManager) {
				var area : Rectangle = new Rectangle(0, 0, controller.width, controller.height);
				adManager.setSize(area, area, AD_MANAGER_SCALE);
			}
		}

		private function stateChange(e : PlayerStateEvent) : void {
			if (controller != null) {
				switch (controller.playerState) {
					case PlayerState.VIDEO_STARTED :
					case PlayerState.VIDEO_PLAYING :
						if (timer != null && !timer.running) {
							timer.reset();
							timer.start();
						}
						break;
					case PlayerState.VIDEO_ENDED :
					case PlayerState.VIDEO_PAUSED :
						if (timer != null) {
							timer.stop();
						}
						break;
				}
			}
		}

		private function onLiveRailLoadComplete(data : *) : void {
			Log.write("LiveRailMonetisation.onLiveRailLoadComplete");
			renderAdManager(data);

			if (qcLRVerticalValue != null || forceAdBreak) {
				initLiveRail();
			} else {
				Log.write("LiveRailMonetisation.onLiveRailLoadComplete * waiting for Quantcast");
			}
		}

		/*VPAID EVENT LISTENERS*/
		private function onVPAIDEventAdLoaded(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdLoaded * event:" + event.toString());
			updateAdvertTime();

			// scope startMuted
			if (controller.placement.startMuted) {
				Log.write("LiveRailMonetisation.onVPAIDEventAdLoaded *should mute playback: " + controller.placement.startMuted);
				muted = true;
			}

			if (adManager.hasOwnProperty("resizeAd")) {
				adManager.resizeAd(controller.width, controller.height, "normal");
			}

			if (adManager.hasOwnProperty("startAd")) {
				adManager.startAd();
			}
		}

		private function onVPAIDEventAdStopped(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdStopped * event:" + event.toString());
			Log.write("LiveRailMonetisation.onVPAIDEventAdStopped * playerState:" + controller.playerState);

			// dump public api
			Log.write(describeType(adManager));
			if (controller.playerState == PlayerState.AD_PAUSED || controller.playerState == PlayerState.AD_PLAYING) {
				Log.write("dispatching.MonetizationEvent.AD_ENDED");
				// adDidNotifyCompletion = true;
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
			}
		}

		private function onVPAIDEventAdStarted(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdStarted * event:" + event.toString());
			// dump public api
			// Log.write(describeType(adManager));
			Log.write("adManager.adLinear: " + adManager.adLinear);

			if (adManager.adLinear) {
				// adDidNotifyCompletion = false;
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_STARTED));
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
			}
		}

		private function onVPAIDEventAdRemainingTimeChange(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdRemainingTimeChange * event:" + event.toString());
			updateAdvertTime();

			if (controller.playerState == PlayerState.AD_PAUSED && isLinearAdShowing()) {
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
			}
		}

		private function onVPAIDEventAdDurationChange(event : Event) : void {
			Log.write("LiveRailMonetisation.onLiveRailAdDurationChange *event: " + event.toString());
			if (!isNaN(adManager.adDuration)) {
				_duration = adManager.adDuration;
				updateAdvertTime();
			}
		}

		private function onVPAIDEventAdExpandedChange(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdExpandedChange *event: " + event.toString());
			if (adManager.adExpanded && !adManager.adLinear) {
				Log.write("**expanded non-linear");
			} else if (!adManager.adExpanded && !adManager.adLinear) {
				Log.write("**unexpanded non-linear");
			}

			if (adManager.adExpanded && adManager.adLinear) {
				Log.write("**expanded linear");
			} else if (!adManager.adExpanded && adManager.adLinear) {
				Log.write("**unexpanded linear");
			}
		}

		private function onVPAIDEventAdVideoStart(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdVideoStart *event: " + event.toString());

			updateAdvertTime();
			// Log.write("adManager.adLinear: " + adManager.adLinear);
			// Log.write("adManager.getVPAID() " + adManager.getVPAID());
			if (controller.playerState == PlayerState.AD_PAUSED) {
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
			}
		}

		private function onVPAIDEventAdVideoComplete(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdVideoComplete *event: " + event.toString());
			// Log.write("adManager.adLinear: " + adManager.adLinear);
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
		}

		private function onVPAIDEventAdLinearChange(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdLinearChange * ad is linear: " + adManager.adLinear + " *event: " + event.toString());
		}

		private function onVPAIDEventAdUserClose(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdUserClose *event: " + event.toString());
		}

		private function onVPAIDEventAdUserMinimize(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdUserMinimize *event: " + event.toString());
		}

		private function onVPAIDEventAdPaused(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdPaused *event: " + event.toString());
			pauseIfPlaying();
		}

		private function onVPAIDEventAdPlaying(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdPlaying *event: " + event.toString());
			if (controller.playerState == PlayerState.AD_PAUSED) {
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
			}
		}

		private function onVPAIDEventAdClickThru(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdClickThru *event: " + event.toString());
			pauseIfPlaying();
		}

		private function onVPAIDEventAdUserAcceptInvitation(event : Event) : void {
			Log.write("LiveRailMonetisation.AdUserAcceptInvitation *event: " + event.toString());
		}

		private function onVPAIDEventAdVolumeChange(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdVolumeChange *event: " + event.toString());
		}

		private function onVPAIDEventAdImpression(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdImpression *event: " + event.toString());
		}

		private function onVPAIDEventAdLog(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdLog *onVPAIDEventAdLog: " + event.toString());
		}

		private function onVPAIDEventAdError(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdError *event: " + event.toString());
			controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "LiveRailMonetisation.onVPAIDEventAdError * " + event.toString() + " * url: " + AD_MANAGER_URL);
			// adDidNotifyCompletion = true;
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
		}

		private function onVPAIDEventAdInteraction(event : Event) : void {
			Log.write("LiveRailMonetisation.onVPAIDEventAdInteraction * event:" + event.toString());
		}

		private function onTimer(evt : TimerEvent) : void {
			// update content time and duration
			adManager.onContentUpdate(controller.getCurrentTime(), controller.getDuration());
		}

		/*
		 * PRIVATE METHODS
		 */
		private function stopAds(evt : MonetizationEvent) : void {
			stopVideo();
		}

		private function pauseIfPlaying() : void {
			Log.write("LiveRailMonetisation.pauseIfPlaying");
			if (controller.playerState == PlayerState.AD_PLAYING || controller.playerState == PlayerState.VIDEO_PLAYING) {
				updateAdvertTime();
				controller.pauseVideo();
			}
		}

		private function initQuantCast() : void {
			Log.write("LiveRailMonetisation.initQuantCast");
			request = new URLRequest(QC_API_URL + controller.placement.pcodeValue);
			controller.loader.load(request, AssetLoader.TYPE_XML, null, false, ErrorCode.ASSET_LOADING_ERROR, "LiveRailMonetisation.initQuantCast", onQcloadComplete, errorHandler);

			timer = new Timer(QC_WAITING_TIME, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, onTimerComplete);
			timer.start();
		}

		private function filterQuantCastID(xml : XML) : void {
			qcLRVerticalValue = "";
			try {
				if (xml.hasOwnProperty("segments")) {
					var segments : XMLList = xml.child("segments");
					for (var i : int = 0; i < segments.length(); i++) {
						if (segments[i].segment.id == QC_SEGMENT_ID) {
							qcLRVerticalValue = String(segments[i].segment.id);
							break;
						}
					}
				}
			} catch(error : Error) {
				Log.write("LiveRailMoentisation.filterQuantCastID *error: " + error.toString());
			}
		}

		private function loadAdManager() : void {
			Log.write("LiveRailMonetisation.loadAdManager");
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_BUFFERING));

			var url : String = "";
			if (controller.placement.forceHTTPS) {
				Security.allowDomain(AD_MANAGER_DOMAIN_SECURE);
				url = AD_MANAGER_URL_SECURE;
			} else {
				Security.allowDomain(AD_MANAGER_DOMAIN);
				url = AD_MANAGER_URL;
			}

			if (!adManagerRenderedWithSuccess) {
				controller.loader.load(new URLRequest(url), AssetLoader.TYPE_SWF, null, false, ErrorCode.ASSET_LOADING_ERROR, "LiveRailMonetisation.loadPlugin * ", onLiveRailLoadComplete, onLiveRailLoadError);
			} else {
				Log.write("LiveRailMonetisation.alreadyLoaded");
				if (qcLRVerticalValue != null || forceAdBreak) {
					initLiveRail();
				} else {
					Log.write("LiveRailMonetisation.onLiveRailLoadComplete * waiting for quantcast xml...");
				}
			}
		}

		private function renderAdManager(data : *) : void {
			Log.write("LiveRailMonetisation.renderAdManager");

			if (!adManager) {
				addChildAt(data as DisplayObject, AD_MANAGER_Z_INDEX);
				adManager = data;

				// LiveRail ==
				adManager.addEventListener(INIT_COMPLETE, onLiveRailInitComplete);
				adManager.addEventListener(INIT_ERROR, onLiveRailInitError);

				// VPAID ==
				adManager.addEventListener(VPAIDEvent.AdLoaded, onVPAIDEventAdLoaded);
				adManager.addEventListener(VPAIDEvent.AdStarted, onVPAIDEventAdStarted);
				adManager.addEventListener(VPAIDEvent.AdStopped, onVPAIDEventAdStopped);
				adManager.addEventListener(VPAIDEvent.AdLinearChange, onVPAIDEventAdLinearChange);
				adManager.addEventListener(VPAIDEvent.AdExpandedChange, onVPAIDEventAdExpandedChange);
				adManager.addEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDEventAdRemainingTimeChange);
				adManager.addEventListener(VPAIDEvent.AdDurationChange, onVPAIDEventAdDurationChange);
				adManager.addEventListener(VPAIDEvent.AdVolumeChange, onVPAIDEventAdVolumeChange);
				adManager.addEventListener(VPAIDEvent.AdImpression, onVPAIDEventAdImpression);
				adManager.addEventListener(VPAIDEvent.AdVideoStart, onVPAIDEventAdVideoStart);
				adManager.addEventListener(VPAIDEvent.AdVideoComplete, onVPAIDEventAdVideoComplete);
				adManager.addEventListener(VPAIDEvent.AdClickThru, onVPAIDEventAdClickThru);
				adManager.addEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDEventAdUserAcceptInvitation);
				adManager.addEventListener(VPAIDEvent.AdUserMinimize, onVPAIDEventAdUserMinimize);
				adManager.addEventListener(VPAIDEvent.AdUserClose, onVPAIDEventAdUserClose);
				adManager.addEventListener(VPAIDEvent.AdPaused, onVPAIDEventAdPaused);
				adManager.addEventListener(VPAIDEvent.AdPlaying, onVPAIDEventAdPlaying);
				adManager.addEventListener(VPAIDEvent.AdLog, onVPAIDEventAdLog);
				adManager.addEventListener(VPAIDEvent.AdError, onVPAIDEventAdError);
				adManager.addEventListener(VPAIDEvent.AdInteraction, onVPAIDEventAdInteraction);

				adManagerRenderedWithSuccess = true;
			}
		}

		private function disposeAdManager() : void {
			Log.write("LiveRailMonetisation.disposeAdManager");

			if (adManagerRenderedWithSuccess) {
				// LiveRail  ==
				adManager.removeEventListener(INIT_COMPLETE, onLiveRailInitComplete);
				adManager.removeEventListener(INIT_ERROR, onLiveRailInitError);

				// VPAID ==
				adManager.removeEventListener(VPAIDEvent.AdLoaded, onVPAIDEventAdLoaded);
				adManager.removeEventListener(VPAIDEvent.AdStarted, onVPAIDEventAdStarted);
				adManager.removeEventListener(VPAIDEvent.AdStopped, onVPAIDEventAdStopped);
				adManager.removeEventListener(VPAIDEvent.AdLinearChange, onVPAIDEventAdLinearChange);
				adManager.removeEventListener(VPAIDEvent.AdExpandedChange, onVPAIDEventAdExpandedChange);
				adManager.removeEventListener(VPAIDEvent.AdRemainingTimeChange, onVPAIDEventAdRemainingTimeChange);
				adManager.removeEventListener(VPAIDEvent.AdDurationChange, onVPAIDEventAdDurationChange);
				adManager.removeEventListener(VPAIDEvent.AdVolumeChange, onVPAIDEventAdVolumeChange);
				adManager.removeEventListener(VPAIDEvent.AdImpression, onVPAIDEventAdImpression);
				adManager.removeEventListener(VPAIDEvent.AdVideoStart, onVPAIDEventAdVideoStart);
				adManager.removeEventListener(VPAIDEvent.AdVideoComplete, onVPAIDEventAdVideoComplete);
				adManager.removeEventListener(VPAIDEvent.AdClickThru, onVPAIDEventAdClickThru);
				adManager.addEventListener(VPAIDEvent.AdUserAcceptInvitation, onVPAIDEventAdUserAcceptInvitation);
				adManager.removeEventListener(VPAIDEvent.AdUserMinimize, onVPAIDEventAdUserMinimize);
				adManager.removeEventListener(VPAIDEvent.AdUserClose, onVPAIDEventAdUserClose);
				adManager.removeEventListener(VPAIDEvent.AdPaused, onVPAIDEventAdPaused);
				adManager.removeEventListener(VPAIDEvent.AdPlaying, onVPAIDEventAdPlaying);
				adManager.removeEventListener(VPAIDEvent.AdLog, onVPAIDEventAdLog);
				adManager.removeEventListener(VPAIDEvent.AdError, onVPAIDEventAdError);
				adManager.removeEventListener(VPAIDEvent.AdInteraction, onVPAIDEventAdInteraction);

				removeChildAt(AD_MANAGER_Z_INDEX);

				adManager.destroy();
				adManager = null;

				adManagerRenderedWithSuccess = false;
			}
		}

		private function initLiveRail() : void {
			Log.write("LiveRailMonetisation.initLiveRail *startMuted: " + controller.placement.startMuted);

			// do stuff for overlays
			adManager.setVolume(VolumeUtils.formatToCodeLevel(controller.getVolume()), controller.isMuted());
			adManager.onContentStart();

			timer = new Timer(OVER_LAY_AD_TIME);
			timer.addEventListener(TimerEvent.TIMER, onTimer);

			if (adManager.hasOwnProperty("handshakeVersion")) {
				adManager.handshakeVersion(VPAID_VERSION);
			}

			if (adManager.hasOwnProperty("setSize")) {
				var area : Rectangle = new Rectangle(0, 0, controller.width, controller.height);
				adManager.setSize(area, area, AD_MANAGER_SCALE);
			}

			if (adManager.hasOwnProperty("initAd")) {
				adManager.initAd(controller.width, controller.height, "normal", 600, "", getAdsConfigAsString());
			}
		}

		private function updateAdvertTime() : void {
			// do not perform update for non-linears
			if (!adManager.adLinear) {
				return;
			}

			var data : Object = getAdvertTimeData();
			Log.write("LiveRailMonetisation.updateAdvertTime remaining time: " + data['remainingTime']);
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_TIMER, data));
		}

		private function getAdvertTimeData() : Object {
			var obj : Object = {};
			obj.time = 0;
			obj.duration = 0;
			obj.remainingTime = 0;

			var remainingTime : int = 0;
			_currentTime = 0;

			if (!isNaN(adManager.adDuration) && adManager.adDuration > 0) {
				_duration = adManager.adDuration;
			} else {
				_duration = 0;
			}

			if (!isNaN(adManager.adRemainingTime) && adManager.adRemainingTime > 0) {
				remainingTime = adManager.adRemainingTime;
			}

			_currentTime = _duration - remainingTime;

			obj.time = _currentTime;
			obj.duration = _duration;
			obj.remainingTime = remainingTime;

			return obj;
		}

		private function getAdsConfig() : Object {
			Log.write("LiveRailMonetisation.getAdsConfig");
			var config : Object = configParams || {};
			var tags : String;
			var width : Number = controller.width;
			var height : Number = controller.height;

			// add in tags not available in the config params
			if (config.hasOwnProperty(LR_TAGS) && config[LR_TAGS] is String) {
				tags = config[LR_TAGS];
				tags += "," + getPlayerTags();
			} else {
				tags = getPlayerTags();
			}

			config[LR_TAGS] = tags;

			// add in  player specific parameters
			config[LR_WIDTH] = width;
			config[LR_HEIGHT] = height;
			config[LR_SDK] = controller.config.PLAYER_TYPE;
			config[LR_USER_AGENT] = getOS();
			// Player viewability?

			config[LR_MUTED] = Number(controller.isMuted());
			config[LR_AUTOPLAY] = Number(getAutoPlay());
			config[LR_URL] = controller.placement.embedPageUrl;

			// test new params
			config[LR_PLAYER_WIDTH] = width;
			config[LR_PLAYER_HEIGHT] = height;
			config[LR_PLAYERSIZE] = getPlayerSize(width, height);

			if (Number(controller.video.durationStr) > 0) {
				config[LR_VIDEO_DURATION] = controller.video.durationStr;
			}

			Log.write("*Liverail ads config is:", Log.DATA);
			for (var key : String in config) {
				Log.write(key + ': ' + config[key]);
			}

			return config;
		}

		private function getAdsConfigAsString() : String {
			var str : String = "";
			var obj : Object = getAdsConfig();
			for (var key : String in obj) {
				str += key + "=" + encodeURIComponent(obj[key]) + "&";
			}

			Log.write("LiveRailMonetisation.getAdsConfigAsString: " + str);

			return str;
		}

		private function getPlayerTags() : String {
			var tags : String = "";

			// playlist position
			tags += LR_PREFIX_PLAYLIST_POSITION + (controller.video.playlistIndex + 1);
			// zero indexed, so add 1
			tags += "," + LR_PREFIX_PLAYER + controller.config.PLAYER_TYPE;

			// add in optional page player tags
			if (controller.placement.pagePlayer) {
				tags += "," + LR_PREFIX_PAGEPLAYER + controller.placement.pagePlayer;
				tags += "," + LR_PREFIX_DISPLAYSTYLE + controller.placement.displayStyle;
				tags += "," + LR_PREFIX_LISTSTYLE + controller.placement.listStyle;
			}

			// append more here...
			// tags += "," + thePrefix + theValue;

			return tags;
		}

		private function getOS() : String {
			return flash.system.Capabilities.os;
		}

		private function getAutoPlay() : Boolean {
			if (controller.placement.showPlaylist && controller.getPlaylistIndex() >= 1) {
				return ((controller.loopMode == LoopMode.PLAYLIST) ? true : false);
			} else {
				return controller.placement.autoPlay;
			}
		}

		private function getPlayerSize(width : Number, height : Number) : uint {
			if (width <= MIN_PLAYER_WIDTH && height <= MIN_PLAYER_HEIGHT) {
				return PLAYERSIZE_SMALL;
			} else if (width > MIN_PLAYER_WIDTH && height > MIN_PLAYER_HEIGHT && width < MAX_PLAYER_WIDTH && height < MAX_PLAYER_HEIGHT) {
				return PLAYERSIZE_MEDIUM;
			} else if (width >= MAX_PLAYER_WIDTH && height >= MAX_PLAYER_HEIGHT) {
				return PLAYERSIZE_LARGE;
			}
			return PLAYERSIZE_UNKNOWN;
		}

		private function isLinearAdShowing() : Boolean {
			return (adManager.adExpanded && adManager.adLinear) ? true : false;
		}
	}
}