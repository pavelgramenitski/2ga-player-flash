package com.rightster.player.model {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.events.ModelEvent;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.PushDataEvent;
	import com.rightster.player.media.IMediaProvider;
	import com.rightster.player.media.IMonetization;
	import com.rightster.player.media.ISimpleVideo;
	import com.rightster.player.media.MediaProvider;
	import com.rightster.player.platform.IPlatform;
	import com.rightster.player.platform.Platforms;
	import com.rightster.player.platform.TwoGA;
	import com.rightster.player.social.ISocialAdapter;
	import com.rightster.player.social.SocialFactory;
	import com.rightster.player.view.BaseColors;
	import com.rightster.player.view.IColors;
	import com.rightster.utils.Log;
	import com.rightster.utils.TimeUtils;

	import flash.display.LoaderInfo;
	import flash.events.Event;
	import flash.events.TimerEvent;
	import flash.net.URLVariables;
	import flash.system.Security;
	import flash.utils.Timer;

	/**
	 * @author Daniel
	 */
	public class Model {
		private static const LOCAL_PROTOCOL : String = "file";
		private const UNAVAILABLE : String = "unavailable";
		private var controller : IController;
		private var loaderInfo : LoaderInfo;
		private var _playerState : int;
		private var _previousPlayerState : int;
		private var _config : Config;
		private var _platform : IPlatform;
		private var _simpleVideo : ISimpleVideo;
		private var _mediaProvider : IMediaProvider;
		private var _monetization : IMonetization;
		private var _flashVars : Object;
		private var _live : Boolean;
		private var _pluginManager : PluginManager;
		private var _placement : MetaPlacement;
		private var screenshot : ScreenshotLoader;
		private var _jsApi : JsApi;
		private var parallelLoading : int;
		private var _cookieManager : CookieManager;
		private var autoPlayNext : Boolean;
		private var playerReady : Boolean;
		private var _rLoader : RLoader;
		private var pushCommandManager : PushCommandManager;
		private var timer : Timer;
		private var _playlist : IPlaylist;
		private var _colors : IColors;
		private var _currentProtocol : String;
		private var socialAdapter : ISocialAdapter;

		public function Model(loaderInfo : LoaderInfo) {
			this.loaderInfo = loaderInfo;
			Security.allowDomain("*");

			// detects whether SWF has been run local
			_live = (loaderInfo.url.substr(0, LOCAL_PROTOCOL.length) == LOCAL_PROTOCOL) ? false : true;

			if (loaderInfo.parameters.hasOwnProperty("live") && loaderInfo.parameters["live"] == "1" ) {
				_live = true;
			} else if (loaderInfo.parameters.hasOwnProperty("live") && loaderInfo.parameters["live"] == "0" ) {
				_live = false;
			}

			Log.write("Model * live: " + _live, Log.SYSTEM);
			Log.write("Model * player URL: " + loaderInfo.url, Log.SYSTEM);
			initFlashVars();
			_config = new Config();
		}

		/*
		 * Public Methods
		 */
		public function initialize(controller : IController) : void {
			Log.write("Model.initialize");
			this.controller = controller;
			_cookieManager = new CookieManager(controller);

			_colors = new BaseColors();
			_colors.initialize();

			controller.addEventListener(ModelEvent.PLAYBACK_AUTHORIZED, state);
			controller.addEventListener(ModelEvent.PLAYLIST_COMPLETE, state);
			controller.addEventListener(ModelEvent.VIDEO_DATA_COMPLETE, state);
			controller.addEventListener(ModelEvent.PLUGINS_COMPLETE, state);
			controller.addEventListener(ModelEvent.SCREENSHOT_COMPLETE, state);
			controller.addEventListener(ModelEvent.MEDIA_COMPLETE, state);
			controller.addEventListener(ModelEvent.COOKIE_COMPLETE, state);

			controller.addEventListener(MediaProviderEvent.STARTED, state);
			controller.addEventListener(MediaProviderEvent.ENDED, state);
			controller.addEventListener(MediaProviderEvent.PLAYING, state);
			controller.addEventListener(MediaProviderEvent.PAUSED, state);
			controller.addEventListener(MediaProviderEvent.BUFFERING, state);
			controller.addEventListener(MediaProviderEvent.REQUEST_AUTHORISATION, state);

			controller.addEventListener(MonetizationEvent.AD_STARTED, state);
			controller.addEventListener(MonetizationEvent.AD_ENDED, state);
			controller.addEventListener(MonetizationEvent.AD_PLAYING, state);
			controller.addEventListener(MonetizationEvent.AD_PAUSED, state);
			controller.addEventListener(MonetizationEvent.AD_BUFFERING, state);

			_playlist = new Playlist(controller);
			_placement = new MetaPlacement(controller);
			_placement.init(_flashVars, loaderInfo.loaderURL);
			_placement.loaderInfoURL = this.loaderInfo.loaderURL;
			// _placement.forceHTTPS = true;

			Log.write("Model * embed page URL" + _placement.embedPageUrl, Log.SYSTEM);
			Log.write("Model * forceHTTPS" + _placement.forceHTTPS, Log.SYSTEM);

			_rLoader = new RLoader(controller, _placement.forceHTTPS);
			screenshot = new ScreenshotLoader(controller);
			_jsApi = new JsApi(controller);
			_playerState = _previousPlayerState = PlayerState.PLAYER_UNSTARTED;
			pushCommandManager = new PushCommandManager(controller);

			controller.addEventListener(PushDataEvent.COMMAND_RECIEVED, handlePushCommands);

			_pluginManager = new PluginManager(controller);
			socialAdapter = SocialFactory.setAdapter(controller.placement.platform);
			socialAdapter.initialize(controller);
		}

		public function getVideoEmbedCode() : String {
			Log.write('Model.getVideoEmbedCode');

			return "";
		}

		public function playVideoAt(index : Number) : void {
			Log.write('Model.playVideoAt * index :  ' + index);

			if (index == -1) {
				if (_playerState == PlayerState.PLAYLIST_ENDED && _playerState != PlayerState.PLAYER_ERROR) {
					Log.write("Model.playVideoAt * PlayerState.PLAYLIST_ENDED and index = -1");
					playVideoAt(_platform.playlist.currentIndex);
				} else if ( _playerState != PlayerState.PLAYER_ERROR && _playerState != PlayerState.PLAYER_BLOCKED) {
					Log.write("Model.playVideoAt * NOT PlayerState.PLAYLIST_ENDED");
					simpleVideo.playVideo();
				}
			} else {
				Log.write("Model.playVideoAt * INDEX NOT NEGATIVE");
				autoPlayNext = true;
				if (_playerState != PlayerState.PLAYER_ERROR) {
					if (isValidIndex(index)) {
						loadVideo(index);
					} else {
						Log.write('Model.playVideoAt * index :  ' + index + " index is not valid", Log.ERROR);
					}
				}
			}
		}

		private function isValidIndex(index : int) : Boolean {
			var maxIndex : int = controller.getPlaylist().playlist.length - 1;
			return index <= maxIndex ? true : false;
		}

		public function connectToPlatform(initObject : Object = null) : void {
			Log.write("Model.connectToPlatform");
			Log.resetTime();

			setPlayerState(PlayerState.PLAYER_UNSTARTED);
			setPlayerState(PlayerState.PLAYER_BUFFERING);

			disposeVideoAssets();

			if (initObject != null) {
				_placement.reset();
				_placement.init(initObject, loaderInfo.loaderURL);
			}

			playerReady = false;

			if (_platform != null) {
				_platform.dispose();
				_platform = null;
			}

//			if (_placement.platform == Platforms.GENESIS) {
//				Log.write("Model * platform GENESIS", Log.SYSTEM);
//				_platform = new Genesis(controller);
//			} else if (_placement.platform == Platforms.DIRECT) {
//				Log.write("Model * platform DIRECT", Log.SYSTEM);
//				_platform = new Direct(controller);
//			} else if (_placement.platform == Platforms.MARS) {
//				Log.write("Model * platform MARS", Log.SYSTEM);
//				_platform = new Mars(controller);
//			} else 
			
			if (_placement.platform == Platforms.TWOGA) {
				Log.write("Model * platform 2GA", Log.SYSTEM);
				_platform = new TwoGA(controller);
			} else {
				controller.error(ErrorCode.INITIALIZATION_ERROR, "Incompatible platform " + _placement.platform, true);
			}

			if (_placement.platform == Platforms.TWOGA) {
				_platform.loadPlaylist();
			}
		}

		public function state(_state : *) : void {
			if (_state is Event) {
				_state = (_state as Event).type;
			} else if (_state is String) {
				_state = _state as String;
			}

			Log.write("Model.state * _state: " + _state);

			switch (_state) {
				case ModelEvent.PLAYBACK_AUTHORIZED :
					Log.write("Model.state * AUTH_PLAYBACK_COMPLETE");
					if (_playerState != PlayerState.PLAYER_ERROR) {
						_mediaProvider.playVideo();
					}
					break;
				case ModelEvent.PLAYLIST_COMPLETE :
					Log.write("Model.state * PLAYLIST COMPLETE");
					if (_placement.cuePlaylists.length > 0) {
						_platform.loadPlaylist(_placement.cuePlaylists.shift());
					} else {
						// load details for first video in playlist
						loadVideo(_platform.playlist.currentIndex);
					}
					break;
				case ModelEvent.VIDEO_DATA_COMPLETE :
					Log.write("Model.state * VIDEO DATA COMPLETE");
					if (_placement.cueVideos.length > 0) {
						_platform.loadVideo(_placement.cueVideos.shift());
					} else if (_placement.cuePlaylists.length > 0) {
						_platform.loadPlaylist(_placement.cuePlaylists.shift());
					} else {
						// load assets the first video in the playlist
						loadVideoAssets();
					}
					break;
				case ModelEvent.PLUGINS_COMPLETE :
				case ModelEvent.SCREENSHOT_COMPLETE :
				case ModelEvent.MEDIA_COMPLETE :
				case ModelEvent.COOKIE_COMPLETE :
					--parallelLoading;
					// Log.write("Model.state * parallelLoading == " + parallelLoading, _state);
					if (parallelLoading == 0) {
						// ready for playback / user interaction
						Log.write("Model.state * parallelLoading complete");

						if (controller.placement.startMuted) _cookieManager.muted = true;
						if (controller.placement.userId) _cookieManager.userId = controller.placement.userId;
						if (controller.placement.userSession) _cookieManager.userSession = controller.placement.userSession;

						initCorePlugins();

						if (!playerReady) {
							playerReady = true;
							setPlayerState(PlayerState.PLAYER_READY);
						}

						setPlayerState(PlayerState.VIDEO_READY);

						if (_placement.autoPlay || autoPlayNext && _playerState != PlayerState.PLAYER_BLOCKED) {
							// Log.write("Model.state * AUTOPLAY is true");
							if (_playerState != PlayerState.PLAYER_ERROR) {
								autoPlayNext = false;
								controller.playVideo();
							}
						} else {
							setPlayerState(PlayerState.VIDEO_CUED);
						}
					}
					break;
				case MediaProviderEvent.STARTED :
					setPlayerState(PlayerState.VIDEO_STARTED);
					break;
				case MediaProviderEvent.PAUSED :
					setPlayerState(PlayerState.VIDEO_PAUSED);
					break;
				case MediaProviderEvent.PLAYING :
					setPlayerState(PlayerState.VIDEO_PLAYING);
					break;
				case MediaProviderEvent.BUFFERING :
				case MonetizationEvent.AD_BUFFERING :
					setPlayerState(PlayerState.PLAYER_BUFFERING);
					break;
				case MediaProviderEvent.ENDED :
					setPlayerState(PlayerState.VIDEO_ENDED);
					// DEV: KJR note - playlist version 2 is poss live with mid roll ads -- 2ga returning version 1 currently: 141124
					if (controller.placement.playlistVersion != 2) {
						// determine if loop required
						if (_playlist.loopMode == LoopMode.PLAYLIST) {
							_platform.playlist.nextVideo();
						} else if (_playlist.loopMode == LoopMode.VIDEO) {
							controller.playVideoAt(controller.getPlaylist().currentIndex);
						} else {
							if (_platform.playlist.isLastVideo()) {
								setPlayerState(PlayerState.PLAYLIST_ENDED);
								// now  load in screenshot of first video in playlist if autoplay
								var firstVideo : MetaVideo = this.playlist.getItemAt(0);
								screenshot.loadAndShowOnComplete(firstVideo.startImageUrl);
							} else {
								_platform.playlist.nextVideo();
							}
						}
					}
					break;
				case MediaProviderEvent.REQUEST_AUTHORISATION :
					if (_playerState != PlayerState.PLAYER_BUFFERING) {
						setPlayerState(PlayerState.PLAYER_BUFFERING);
						_platform.requestPlaybackAuth();
					}
					break;
				case MonetizationEvent.AD_STARTED :
					setPlayerState(PlayerState.AD_STARTED);
					break;
				case MonetizationEvent.AD_PAUSED :
					setPlayerState(PlayerState.AD_PAUSED);
					break;
				case MonetizationEvent.AD_PLAYING :
					setPlayerState(PlayerState.AD_PLAYING);
					break;
				case MonetizationEvent.AD_ENDED :
					setPlayerState(PlayerState.AD_ENDED);
					if (_playerState != PlayerState.PLAYER_ERROR) {
						_simpleVideo = _mediaProvider;
						_simpleVideo.volume = _cookieManager.volume;
						_simpleVideo.muted = _cookieManager.muted;
						_simpleVideo.playVideo();
					}
					break;
			}
		}

		public function error(code : String, message : String, blocking : Boolean = false) : void {
			Log.write("Model.error *  code: " + code + "  message: " + message + "  blocking: " + blocking, Log.ERROR);
			// IMPORTANT: in the case of shared object unavailability, this may be before the controller and model have been created and received any values. Report 'unavailable' to prevent an unhandleable exception
			var xvid : String = (controller.placement && controller.placement.initialId) ? controller.placement.initialId : UNAVAILABLE;
			var ref : String = (controller.placement && controller.placement.href) ? controller.placement.href : UNAVAILABLE;
			var uid : String = (controller.placement && controller.placement.userId) ? controller.placement.userId : UNAVAILABLE;
			var sid : String = (controller.placement && controller.placement.userSession) ? String(controller.placement.userSession) : UNAVAILABLE;
			var bitrate : String;

			if (_cookieManager && _cookieManager.quality && _cookieManager.quality != "") {
				bitrate = _cookieManager.quality;
			} else if (controller.placement && controller.placement.defaultQuality) {
				bitrate = controller.placement.defaultQuality;
			} else {
				bitrate = UNAVAILABLE;
			}

			var errorObj : URLVariables = new URLVariables();
			errorObj['xvid'] = xvid;
			errorObj['error_code'] = code;
			errorObj['error_message'] = message;
			errorObj['player_log'] = Log.exportLog();
			errorObj['ref'] = ref;
			errorObj['uid'] = uid;
			errorObj['sid'] = sid;
			errorObj['player'] = 'flash';
			errorObj['bitrate'] = bitrate;

			// TODO:KJR check round trip to here from controller
			if (blocking) {
				if (controller.placement.showPlaylist && code == ErrorCode.MEDIA_URLS_EMPTY) {
					
					// TODO: KJR check is this valid for all platforms or just Genesis? // below commented out already
					// controller.nextVideo();
				} else {
					setPlayerState(PlayerState.PLAYER_ERROR);
					if (_simpleVideo != null) _simpleVideo.dispose();
					if (_mediaProvider != null) _mediaProvider.dispose();
				}
			}
		}

		/*
		 * Getters/Setters
		 */
		public function get playerState() : int {
			return _playerState;
		}

		public function get config() : Config {
			return _config;
		}

		public function get live() : Boolean {
			return _live;
		}

		public function get placement() : MetaPlacement {
			return _placement;
		}

		public function get flashVars() : Object {
			return _flashVars;
		}

		public function get mediaProvider() : IMediaProvider {
			return _mediaProvider;
		}

		public function get simpleVideo() : ISimpleVideo {
			return _simpleVideo;
		}

		// shortcut to the current stream
		public function get stream() : MetaStream {
			return video == null ? null : video.metaStreams[controller.getPlaybackQuality()] as MetaStream;
		}

		public function get monetisation() : IMonetization {
			return _monetization;
		}

		public function get cookieManager() : CookieManager {
			return _cookieManager;
		}

		public function get playlist() : IPlaylist {
			return _playlist;
		}

		public function get playlistIndex() : uint {
			return _platform.playlist.currentIndex;
		}

		public function get colors() : IColors {
			return _colors;
		}

		public function set colors(value : IColors) : void {
			_colors = value;
		}

		public function get currentProtocol() : String {
			return _currentProtocol;
		}

		public function set currentProtocol(value : String) : void {
			_currentProtocol = value;
		}

		// shortcut to the current video
		public function get video() : MetaVideo {
			return _platform == null ? null : _platform.playlist.getItemAt(_platform.playlist.currentIndex);
		}

		public function get loader() : RLoader {
			return _rLoader;
		}

		public function get availableQualityLevels() : Array {
			return controller.video.qualities;
		}

		public function set playbackQuality(suggestedQuality : String) : void {
			Log.write("Model set playbackQuality * suggestedQuality:" + suggestedQuality);
			if (mediaProvider != null) {
				// isAvailableQuality(suggestedQuality);

				if (suggestedQuality == controller.config.AUTO) {
					mediaProvider.autoSelectQuality = true;
					mediaProvider.setPlaybackQuality(suggestedQuality);
				} else {
					mediaProvider.autoSelectQuality = false;
					mediaProvider.setPlaybackQuality(suggestedQuality);
				}
			}
		}

		public function get platform() : IPlatform {
			return _platform;
		}

		public function get jsApi() : JsApi {
			return _jsApi;
		}

		/*
		 * Private Methods
		 */
		private function setPlayerState(state : Number) : void {
			if (state != _playerState && _playerState != PlayerState.PLAYER_BLOCKED) {
				var oldState : int = _playerState;
				_playerState = state;
				Log.write("Model.setPlayerState * " + state, Log.SYSTEM);
				controller.dispatchEvent(new PlayerStateEvent(PlayerStateEvent.CHANGE, state, oldState));
			}
		}

		private function initFlashVars() : void {
			// if live, use real FlashVars, else use local TestVars.txt
			Log.write('Model.initFlashVars');
			var obj : Object = {};

			if (_live) {
				obj = loaderInfo.parameters;
			} else {
				obj = TestVars.getVars();
			}

			_flashVars = {};

			for (var key : String in obj) {
				_flashVars[key.toLowerCase()] = obj[key];
				Log.write("FlashVars * key:" + key.toLowerCase() + " value: " + _flashVars[key.toLowerCase()], Log.DATA);
			}
		}

		private function loadVideo(index : uint) : void {
			Log.write("Model.loadVideo * index :" + index);
			setPlayerState(PlayerState.PLAYER_BUFFERING);
			_platform.playlist.currentIndex = index;
			// edwardhunton
			/*if(_flashVars.startmuted == '1'){
				controller.mute();
			}*/
			var metaVideo : MetaVideo = (_platform.playlist.getItemAt(index) as MetaVideo);

			if (metaVideo.dataLoaded) {
				loadVideoAssets();
			} else {
				_platform.loadVideo(metaVideo.videoId);
			}
		}

		private function loadVideoAssets() : void {
			Log.write("Model.loadVideoAssets");
			disposeVideoAssets();
			parallelLoading = 0;

			// media provider specific behaviourgit status
			switch (video.mediaProvider) {
				case MediaProvider.AKAMAI_LIVE :
				case MediaProvider.VIDEO_MEDIA_PROVIDER :
				case MediaProvider.LIVE_MEDIA_PROVIDER :
					// TODO: KJR at this point we willnot know the quality required because the media provider has not yet loaded. Does this have to match the qulaity of the video or just be an agreed type...
					if (!_placement.autoPlay && !autoPlayNext) {
						parallelLoading++;
						screenshot.load(video.startImageUrl);
					}
					break;
			}

			// load all plugins
			parallelLoading++;
			_pluginManager.runPlugins(video.metaPlugins);
		}

		private function checkUserId(event : TimerEvent) : void {
			if (_cookieManager.userId == "requested") {
				return;
			}

			timer.removeEventListener(TimerEvent.TIMER, checkUserId, false);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timeOut, false);
			timer.stop();
			timer = null;

			_placement.userId = _cookieManager.userId;
			_placement.userSession = _cookieManager.userSession + 1;

			controller.dispatchEvent(new ModelEvent(ModelEvent.COOKIE_COMPLETE));
		}

		private function timeOut(event : TimerEvent) : void {
			timer.removeEventListener(TimerEvent.TIMER, checkUserId, false);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timeOut, false);
			timer.stop();
			timer = null;
			controller.dispatchEvent(new ModelEvent(ModelEvent.COOKIE_COMPLETE));
		}

		private function initCorePlugins() : void {
			try {
				var media : uint = 0;
				var monet : uint = 0;
				var plugins : Array = _pluginManager.activePlugins;

				for (var i : int = 0; i < plugins.length; i++) {
					if ((plugins[i] as IPlugin) is IMonetization) {
						_monetization = (plugins[i] as IPlugin) as IMonetization;
						monet++;
					} else if ((plugins[i] as IPlugin) is IMediaProvider) {
						_mediaProvider = (plugins[i] as IPlugin) as IMediaProvider;
						media++;
					}
				}

				if (media != 1) {
					controller.error(ErrorCode.INTEGRITY_ERROR, "Model.initCorePlugins * number of MediaProviders is not 1 but " + media, true);
					setPlayerState(PlayerState.PLAYER_BLOCKED);
					return;
				}

				if (_playerState != PlayerState.PLAYER_ERROR && _playerState != PlayerState.PLAYER_BLOCKED) {
					_mediaProvider.setPlaybackQuality(_cookieManager.quality);
				}

				// determine whether to run ad or standard video
				_simpleVideo = shouldUseMonetization() ? _monetization : _mediaProvider;
				_simpleVideo.volume = _cookieManager.volume;
				_simpleVideo.muted = _cookieManager.muted;
			} catch(error : Error) {
				Log.write("Model.initCorePlugins * error: " + error.toString(), Log.ERROR);
			}
		}

		private function disposeVideoAssets(e : TimerEvent = null) : void {
			Log.write("Model.disposeVideoAssets");
			if (screenshot != null) {
				screenshot.dispose();
			}

			_pluginManager.closeActivePlugins();
			_mediaProvider = null;
			_simpleVideo = null;
			_monetization = null;
		}

		private function handlePushCommands(event : PushDataEvent) : void {
			var dataString : String = "";
			var data : Object = new Object();

			for (var key : String in event.data) {
				dataString += key + "=" + event.data[key] + ", ";
				data[key.toLowerCase()] = event.data[key];
			}

			Log.write("Model.handlePushCommands * command : " + event.command + ", data : " + dataString);
			switch(event.command) {
				case PushCommands.AD_BREAK :
					var adCount : int = 1;
					var spread : int = 0;
					if (data) {
						if (data.hasOwnProperty("adcount")) {
							adCount = int(data["adcount"]) <= 5 ? int(data["adcount"]) : 5;
						}

						if (data.hasOwnProperty("spread")) {
							spread = int(data["spread"]);
						}
					}
					if (_monetization != null) {
						Log.write("Adbreak request will be sent in " + spread + " seconds");

						var timer : Timer = new Timer(spread * 1000, 1);
						timer.addEventListener(TimerEvent.TIMER_COMPLETE, forceAdBreak);
						timer.start();
					}
					break;
				case PushCommands.UPDATE_TIME :
					var idx : int = int(data['index']);
					if (idx >= 0 && idx < controller.getPlaylist().length) {
						var itm : MetaVideo = _platform.playlist.getItemAt(idx);
						itm.startTime = TimeUtils.toSeconds(String(data['starttime']));
						itm.endTime = TimeUtils.toSeconds(String(data['endtime']));
						_platform.playlist.removeItemAt(idx);
						_platform.playlist.insertItem(itm, idx);
					}
					break;
			}
		}

		private function forceAdBreak(event : TimerEvent) : void {
			if (controller.playerState == PlayerState.VIDEO_PLAYING) {
				controller.placement.forceadBreak = true;
				_simpleVideo.pauseVideo();
				_simpleVideo = _monetization;
				_simpleVideo.volume = _cookieManager.volume;
				_simpleVideo.muted = _cookieManager.muted;
				_simpleVideo.playVideo();
			}
		}

		private function shouldUseMonetization() : Boolean {
			var value : Boolean = (_monetization != null && placement.shouldMonetize ) ? true : false;

			Log.write("placement.shouldMonetize  ** " + placement.shouldMonetize);

			/*if (CONFIG::DEBUG) {
				// NOTE: override here to test and debug ad serving in debug environment
				// value = false;
			}*/
			Log.write("Model.shouldUseMonetization ** " + value);
			return value;
		}

		public function shareTwitter() : void {
			socialAdapter.shareTwitter();
		}

		public function shareFacebook() : void {
			socialAdapter.shareFacebook();
		}

		public function shareTumblr() : void {
			socialAdapter.shareTumblr();
		}

		public function shareEmail() : void {
			socialAdapter.shareEmail();
		}

		public function shareGPlus() : void {
			socialAdapter.shareGPlus();
		}
		// private function isAvailableQuality(suggestedQuality : String) : Boolean {
		// Log.write("Model.isAvailableQuality * suggestedQuality: " + suggestedQuality);
		// var success : Boolean = false;
		// for (var key : String in video.metaQualities) {
		// Log.write('video.metaQualities[key]');
		// Log.write(video.metaQualities[key]);
		// }
		//
		// return false;
		//			//  true
		// }
	}
}