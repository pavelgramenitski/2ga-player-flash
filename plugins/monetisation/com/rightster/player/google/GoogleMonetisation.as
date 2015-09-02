package com.rightster.player.google {
	import com.google.ads.ima.api.ViewModes;
	import com.google.ads.ima.api.AdEvent;
	import com.google.ads.ima.api.AdsRequest;
	import com.google.ads.ima.api.AdsRenderingSettings;
	import com.google.ads.ima.api.AdsManager;
	import com.google.ads.ima.api.AdErrorEvent;
	import com.google.ads.ima.api.AdsManagerLoadedEvent;
	import com.google.ads.ima.api.AdsLoader;
	import com.rightster.player.events.PlayerStateEvent;
	// import com.rightster.player.model.LoopMode;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.media.IMonetization;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.player.Version;
	import com.rightster.utils.Log;
	import com.rightster.utils.AssetLoader;
	import com.rightster.utils.VolumeUtils;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.utils.Timer;

	/**
	 * @author KJR
	 */
	public class GoogleMonetisation extends MovieClip implements IMonetization , IPlugin {
		// Quantcast Constants
		private static const QC_API_URL : String = "http://pixel.quantserve.com/api/segments.xml?a=";
		private static const QC_SEGMENT_ID : String = "15437";
		private static const QC_WAITING_TIME : uint = 30000;
		// Plugin
		private static const Z_INDEX : int = PluginZindex.BELOW_CHROME;
		private var controller : IController;
		private var quantcastLRVerticalValue : String;
		private var timer : Timer;
		private var adsLoaderIsInitialized : Boolean;
		private var request : URLRequest;
		private var forceAdBreak : Boolean;
		private var requestAdsIsDirty : Boolean;
		private var volumeIsDirty : Boolean;
		private var mutedIsDirty : Boolean;
		private var retainedVolume : Number;
		private var retainedMuted : Boolean;
		private var _loaded : Boolean = true;
		private var _initialized : Boolean;
		// Google ads specific
		private static const LINEAR_AD_TAG : String = "http://pubads.g.doubleclick.net/gampad/ads?sz=640x480&iu=/105416511/Test&ciu_szs&impl=s&gdfp_req=1&env=vp&output=xml_vast2&unviewed_position_start=1&url=[referrer_url]&description_url=[description_url]&correlator=[timestamp]&cust_params=test%3DtestValue";
		private static const HANDSHAKE_VERSION : String = "1.0";
		private static const GOOGLE_ADSLOADER_INITIALIZED : String = "GoogleMonetisation.GOOGLE_ADSLOADER_INITIALIZED";
		private var adsLoader : AdsLoader;
		private var adsManager : AdsManager;

		public function GoogleMonetisation() {
			Log.write("GoogleMonetisation * version: " + Version.VERSION, Log.SYSTEM);
		}

		/*
		 * PUBLIC METHODS
		 */
		public function initialize(controller : IController, data : Object) : void {
			Log.write("GoogleMonetisation.initialize");

			if (!initialized) {
				this.controller = controller;

				controller.addEventListener(ResizeEvent.RESIZE, resizeHandler);
				controller.addEventListener(PlayerStateEvent.CHANGE, playerStateChangeHandler);
				controller.addEventListener(MonetizationEvent.AD_STOP, monetizationAdStopHandler);

				requestAdsIsDirty = false;
				adsLoaderIsInitialized = false;
				forceAdBreak = false;

				initQuantCast();
			}
		}

		public function run(data : Object) : void {
			adsManager.start();
		}

		public function close() : void {
			dispose();
		}

		public function dispose() : void {
			Log.write("GoogleMonetisation.dispose");
			destroyAdsManager();
			destroyAdsLoader();

			controller.removeEventListener(ResizeEvent.RESIZE, resizeHandler);
			controller.removeEventListener(PlayerStateEvent.CHANGE, playerStateChangeHandler);
			controller.removeEventListener(MonetizationEvent.AD_STOP, monetizationAdStopHandler);
			controller = null;
			_initialized = false;
		}

		public function playVideo() : void {
			Log.write("GoogelMonetization.playVideo");
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.VIDEO_CUED :
					if (controller.placement.playlistVersion != 2 || (controller.placement.playlistVersion == 2 && controller.getPlaylistIndex() == 0)) {
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_REQUESTED));
						loadAds();
					} else {
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
					}
					break;
				case PlayerState.AD_PAUSED :
					if (adsManager) {
						adsManager.resume();
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
					}
					break;
				case PlayerState.VIDEO_PAUSED :
					if (controller.placement.playlistVersion == 2 || controller.placement.livePlaylist) {
						controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_REQUESTED));
						forceAdBreak = true;
						loadAds();
					}
					break;
			}
		}

		public function pauseVideo() : void {
			if (adsManager && controller.playerState == PlayerState.AD_PLAYING) {
				adsManager.pause();
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PAUSED));
			}
		}

		public function stopVideo() : void {
			if (adsManager) {
				adsManager.stop();
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
			}
		}

		public function seekTo(seconds : Number, allowSeekAhead : Boolean) : void {
			// not implemented
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
			if (adsManager) {
				adsManager.volume = VolumeUtils.formatToCodeLevel(n);
			} else {
				volumeIsDirty = true;
				retainedVolume = n;
			}
		}

		public function set muted(b : Boolean) : void {
			if (adsManager) {
				adsManager.volume = (b) ? 0 : VolumeUtils.formatToCodeLevel(controller.getVolume());
			} else {
				mutedIsDirty = true;
				retainedMuted = b;
			}
		}

		/*
		 * EVENT HANDLERS
		 */
		private function adsLoadErrorHandler(event : AdErrorEvent) : void {
			var code : int = event.error.errorCode;
			var type : String = event.error.errorType;
			var message : String = event.error.errorMessage;
			controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "GoogleMonetisation.adsLoadErrorHandler * errorCode:" + code + " * errorType: " + type + " * errorMessage: " + message);
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
		}

		/**
		 * Errors that occur during ads manager play should be treated as
		 * informational signals. The SDK will send all ads completed event if there
		 * are no more ads to display.
		 */
		private function adsManagerAdErrorEventHandler(event : AdErrorEvent) : void {
			Log.write("GoogleMonetisation.adsManagerAdErrorEventHandler");
			var code : int = event.error.errorCode;
			var type : String = event.error.errorType;
			var message : String = event.error.errorMessage;
			controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "GoogleMonetisation.adsManagerAdErrorEventHandler * errorCode:" + code + " * errorType: " + type + " * errorMessage: " + message);
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
		}

		/**
		 * Invoked when the AdsLoader successfully fetched ads.
		 */
		private function adsManagerLoadedHandler(event : AdsManagerLoadedEvent) : void {
			Log.write("GoogleMonetisation.adsManagerLoadedHandler * sdkVersion: " + adsLoader.sdkVersion, Log.SYSTEM);

			// Modify the default preferences through this object.
			var adsRenderingSettings : AdsRenderingSettings = new AdsRenderingSettings();

			// In order to support ad rules playlists, ads manager requires an object that provides current playhead position for the content.
			var contentPlayhead : Object = {};

			contentPlayhead.time = function() : Number {
				return controller.getCurrentTime() * 1000;
				// TODO: check need to convert to milliseconds
			};

			// Get a reference to the AdsManager object through the event object.
			adsManager = event.getAdsManager(contentPlayhead, adsRenderingSettings);

			if (adsManager) {
				registerAdEventListeners();

				// If player supports a specific version of VPAID ads, pass in the version.
				// If player does not support VPAID ads yet,just pass in 1.0.
				adsManager.handshakeVersion(HANDSHAKE_VERSION);

				// Init should be called before playing the content in order for ad rules ads to function correctly.
				adsManager.init(controller.width, controller.height, ViewModes.NORMAL);

				// Add the adsContainer to the display list and start playback
				addChildAt(adsManager.adsContainer as DisplayObject, 0);
				adsManager.start();
			}
		}

		private function adsLoaderInitializedHandler(event : Event) : void {
			removeEventListener(GOOGLE_ADSLOADER_INITIALIZED, adsLoaderInitializedHandler);
			requestAds(LINEAR_AD_TAG);
		}

		/**
		 * The AdsManager raises this event when the ad has started.
		 */
		private function startedHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.startedHandler * skippable: " + adsManager.currentAd.skippable);
			if (volumeIsDirty) {
				volumeIsDirty = false;
				volume = retainedVolume;
			}

			if (mutedIsDirty) {
				mutedIsDirty = false;
				muted = retainedMuted;
			}

			if (adsManager.currentAd.skippable) {
				// post notification that ad is skippable but disallow until the adsManager informs that the ad(s) can actually be skipped
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_SKIPPABLE));
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_DISALLOW_SKIP));
			} else {
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_NOT_SKIPPABLE));
			}

			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_STARTED));
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
		}

		private function contentPauseRequestedHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.contentPauseRequestedHandler");
		}

		private function contentResumeRequestedHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.contentResumeRequestedHandler");
		}

		private function remainingTimeChangedHandler(event : AdEvent) : void {
			var remaining : Number = Math.ceil(adsManager.currentAd.remainingTime);
			var current : Number = adsManager.currentAd.currentTime;
			var duration : Number = adsManager.currentAd.duration;
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_TIMER, {time:current, duration:duration, remainingTime:remaining}));
		}

		private function adClickedHandler(event : AdEvent) : void {
			// Log.write("GoogleMonetisation.adClickedHandler");
			if (controller.playerState == PlayerState.AD_PLAYING || controller.playerState == PlayerState.VIDEO_PLAYING) {
				pauseVideo();
			}
		}

		private function allAdsCompletedHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.allAdsCompletedHandler");
			prerollComplete();

			// dispose?
			// destroyAdsManager();
		}

		private function contentCompletedHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.contentCompletedHandler");
		}

		private function skippableStateChangedHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.skippableStateChangedHandler * adSkippableState: " + adsManager.currentAd.adSkippableState);
			var eventType : String = (adsManager.currentAd.adSkippableState) ? MonetizationEvent.AD_ALLOW_SKIP : MonetizationEvent.AD_DISALLOW_SKIP;

			if (adsManager.currentAd.skippable) {
				controller.dispatchEvent(new MonetizationEvent(eventType));
			}
		}

		private function skippedHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.skippedHandler");
		}

		private function adBreakReadyHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.adBreakReadyHandler");
		}

		private function adMetadataHandler(event : AdEvent) : void {
			Log.write("GoogleMonetisation.adMetadataHandler");
		}

		private function errorHandler() : void {
			// Log.write("GoogleMonetisation.errorHandler");
			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
				timer = null;
			}

			quantcastLRVerticalValue = "";

			if (!adsLoaderIsInitialized) {
				initAdsLoader();
			}
		}

		private function quantcastLoadCompleteHandler(result : XML) : void {
			Log.write("GoogleMonetisation.quantcastLoadCompleteHandler * " + result);

			if (timer) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
				timer = null;
			}

			try {
				filterQuantCastID(result);
			} catch (error : Error) {
				controller.error(ErrorCode.XML_PARSING_ERROR, "GoogleMonetisation.quantcastLoadCompleteHandler * " + error.message + " * QC_API_URL: " + QC_API_URL + " * QUANT_CAST_ID :- " + controller.placement.pcodeValue);
			}

			if (!adsLoaderIsInitialized) {
				initAdsLoader();
			}
		}

		private function resizeHandler(event : ResizeEvent = null) : void {
			if (adsManager) {
				adsManager.resize(controller.width, controller.height, ViewModes.NORMAL);
			}
		}

		private function playerStateChangeHandler(e : PlayerStateEvent) : void {
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

		private function monetizationAdStopHandler(evt : MonetizationEvent) : void {
			stopVideo();
		}

		/*
		 * PRIVATE METHODS
		 * 
		 */
		private function loadAds() : void {
			Log.write("GoogleMonetisation.loadAds");
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_BUFFERING));

			if (adsLoaderIsInitialized) {
				requestAds(LINEAR_AD_TAG);
			} else if (!requestAdsIsDirty) {
				// listen for adsLoaderIsInitialized event
				requestAdsIsDirty = true;
				addEventListener(GOOGLE_ADSLOADER_INITIALIZED, adsLoaderInitializedHandler);
			}
		}

		private function registerAdEventListeners() : void {
			adsManager.addEventListener(AdEvent.STARTED, startedHandler);
			adsManager.addEventListener(AdEvent.CLICKED, adClickedHandler);

			adsManager.addEventListener(AdEvent.CONTENT_PAUSE_REQUESTED, contentPauseRequestedHandler);
			adsManager.addEventListener(AdEvent.CONTENT_RESUME_REQUESTED, contentResumeRequestedHandler);

			adsManager.addEventListener(AdEvent.REMAINING_TIME_CHANGED, remainingTimeChangedHandler);

			adsManager.addEventListener(AdEvent.SKIPPABLE_STATE_CHANGED, skippableStateChangedHandler);
			adsManager.addEventListener(AdEvent.SKIPPED, skippedHandler);
			adsManager.addEventListener(AdEvent.AD_BREAK_READY, adBreakReadyHandler);
			adsManager.addEventListener(AdEvent.AD_METADATA, adMetadataHandler);

			adsManager.addEventListener(AdEvent.COMPLETED, contentCompletedHandler);
			adsManager.addEventListener(AdEvent.ALL_ADS_COMPLETED, allAdsCompletedHandler);
			adsManager.addEventListener(AdErrorEvent.AD_ERROR, adsManagerAdErrorEventHandler);
		}

		private function unregisterAdEventListeners() : void {
			adsManager.removeEventListener(AdEvent.STARTED, startedHandler);
			adsManager.addEventListener(AdEvent.CLICKED, adClickedHandler);

			adsManager.removeEventListener(AdEvent.CONTENT_PAUSE_REQUESTED, contentPauseRequestedHandler);
			adsManager.removeEventListener(AdEvent.CONTENT_RESUME_REQUESTED, contentResumeRequestedHandler);

			adsManager.removeEventListener(AdEvent.REMAINING_TIME_CHANGED, remainingTimeChangedHandler);

			adsManager.removeEventListener(AdEvent.SKIPPABLE_STATE_CHANGED, skippableStateChangedHandler);
			adsManager.removeEventListener(AdEvent.SKIPPED, skippedHandler);
			adsManager.removeEventListener(AdEvent.AD_BREAK_READY, adBreakReadyHandler);
			adsManager.removeEventListener(AdEvent.AD_METADATA, adMetadataHandler);

			adsManager.removeEventListener(AdEvent.COMPLETED, contentCompletedHandler);
			adsManager.removeEventListener(AdEvent.ALL_ADS_COMPLETED, allAdsCompletedHandler);
			adsManager.removeEventListener(AdErrorEvent.AD_ERROR, adsManagerAdErrorEventHandler);
		}

		private function initAdsLoader() : void {
			// controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_BUFFERING));

			Log.write("GoogleMonetisation.initAdsLoader");

			if (adsLoader == null) {
				adsLoader = new AdsLoader();

				adsLoader.addEventListener(AdsManagerLoadedEvent.ADS_MANAGER_LOADED, adsManagerLoadedHandler);
				adsLoader.addEventListener(AdErrorEvent.AD_ERROR, adsLoadErrorHandler);
			}

			// sdk
			adsLoader.loadSdk();

			adsLoaderIsInitialized = true;

			if (requestAdsIsDirty) {
				requestAdsIsDirty = false;
				dispatchEvent(new Event(GOOGLE_ADSLOADER_INITIALIZED));
			}
		}

		/**
		 * Request ads using the specified ad tag.
		 *
		 * @param adTag A URL that will return a valid VAST response.
		 */
		private function requestAds(adTag : String) : void {
			Log.write("GoogleMonetisation.requestAds * tag:" + adTag, Log.SYSTEM);
			var adsRequest : AdsRequest = new AdsRequest();

			adsRequest.adTagUrl = adTag;
			adsRequest.linearAdSlotWidth = controller.width;
			adsRequest.linearAdSlotHeight = controller.height;
			adsRequest.nonLinearAdSlotWidth = controller.width;
			adsRequest.nonLinearAdSlotHeight = controller.height;

			// now make request
			adsLoader.requestAds(adsRequest);
		}

		private function destroyAdsManager() : void {
			if (adsManager) {
				unregisterAdEventListeners();

				if (adsManager.adsContainer.parent && adsManager.adsContainer.parent.contains(adsManager.adsContainer)) {
					adsManager.adsContainer.parent.removeChild(adsManager.adsContainer);
				}

				adsManager.destroy();
				adsManager = null;
			}
		}

		private function destroyAdsLoader() : void {
			if (adsLoader) {
				adsLoader.removeEventListener(AdsManagerLoadedEvent.ADS_MANAGER_LOADED, adsManagerLoadedHandler);
				adsLoader.removeEventListener(AdErrorEvent.AD_ERROR, adsLoadErrorHandler);
				adsLoader.destroy();
				adsLoader = null;
			}
		}

		private function prerollComplete() : void {
			Log.write("GoogleMonetisation.prerollComplete");
			controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_ENDED));
		}

		private function timerCompleteHandler(event : TimerEvent) : void {
			// Log.write("GoogleMonetisation.timerCompleteHandler");
			errorHandler();
		}

		private function initQuantCast() : void {
			Log.write("GoogleMonetisation.initQuantCast", Log.SYSTEM);

			request = new URLRequest(QC_API_URL + controller.placement.pcodeValue);
			controller.loader.load(request, AssetLoader.TYPE_XML, null, false, ErrorCode.ASSET_LOADING_ERROR, "GoogleMonetisation.initQuantCast", quantcastLoadCompleteHandler, errorHandler);

			timer = new Timer(QC_WAITING_TIME, 1);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteHandler);
			timer.start();
		}

		private function filterQuantCastID(xml : XML) : void {
			Log.write("GoogleMonetisation.filterQuantCastID");

			quantcastLRVerticalValue = "";

			if (xml.hasOwnProperty("segments")) {
				var segments : XMLList = xml['segments'];

				for (var i : int = 0, j : int = segments.length(); i < j; i++) {
					if (segments[i].segment.id == QC_SEGMENT_ID) {
						quantcastLRVerticalValue = String(segments[i].segment.id);
						break;
					}
				}
			}
		}
		// private function getAutoPlay() : Boolean {
		// if (controller.placement.showPlaylist && controller.getPlaylistIndex() >= 1) {
		// return ((controller.loopMode == LoopMode.PLAYLIST_LOOP) ? true : false);
		// } else {
		// return controller.placement.autoPlay;
		// }
		// }

		// private function getPlayerSize(width : Number, height : Number) : String {
		// if (width <= MIN_PLAYER_WIDTH && height <= MIN_PLAYER_HEIGHT) {
		// return PLAYERSIZE_SMALL;
		// } else if (width > MIN_PLAYER_WIDTH && height > MIN_PLAYER_HEIGHT && width < MAX_PLAYER_WIDTH && height < MAX_PLAYER_HEIGHT) {
		// return PLAYERSIZE_MEDIUM;
		// } else if (width >= MAX_PLAYER_WIDTH && height >= MAX_PLAYER_HEIGHT) {
		// return PLAYERSIZE_LARGE;
		// }
		// return null;
		// }
	}
}