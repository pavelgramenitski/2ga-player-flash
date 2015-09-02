package com.rightster.player.media {
	import com.akamai.events.MediaInspectorEvent;
	import com.akamai.media.MediaInspector;
	import com.akamai.media.MediaType;
	import com.akamai.net.AkamaiNetLoader;
	import com.akamai.net.f4f.hds.AkamaiStreamController;
	import com.akamai.net.f4f.hds.events.AkamaiHDSEvent;
	import com.akamai.playeranalytics.AnalyticsPluginLoader;
	import com.rightster.player.Version;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.events.TimedPlaylistEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.MetaQuality;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;
	import com.rightster.utils.VolumeUtils;

	import org.openvideoplayer.events.OvpEvent;
	import org.openvideoplayer.net.OvpConnection;

	import flash.display.MovieClip;
	import flash.errors.IllegalOperationError;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.events.UncaughtErrorEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetStream;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;

	/**
	 * @author Rightster
	 */
	public class AkamaiLiveStream extends MovieClip implements IMediaProvider, IPlugin {
		private static const Z_INDEX : int = PluginZindex.NONE;
		private static const MEDIA_ANALYTICS_SWF : String = "http://79423.analytics.edgesuite.net/csma/plugin/csma.swf";
		private static const MEDIA_ANALYTICS_SECURE_SWF : String = "https://79423.analytics.edgekey.net/csma/plugin/csma.swf";
		private static const MEDIA_ANALYTICS_CONFIG : String = "http://ma262-r.analytics.edgesuite.net/config/beacon-3170.xml";
		private static const MEDIA_ANALYTICS_SECURE_CONFIG : String = "https://ma262-r.analytics.edgekey.net/config/beacon-4986.xml";
		private var controller : IController;
		private var video : Video;
		private var streamController : AkamaiStreamController;
		private var mediaInspector : MediaInspector;
		private var netLoader : AkamaiNetLoader;
		private var streamUrl : String;
		private var transformer : SoundTransform;
		private var playbackQuality : String;
		private var playbackQualityIndex : int;
		private var playbackStarted : Boolean;
		private var pauseAfterResume : Boolean;
		private var timeOffset : Number = 0;
		private var skipFirstStop : Boolean;
		private var mediaAnalyticsConfigUrl : String;
		private var positionIntervalId : uint;
		private var loggedNetStatusCode : String;
		private var _netConnection : OvpConnection;
		private var _netStream : NetStream;
		private var _duration : Number = 0;
		private var _loaded : Boolean = true;
		private var _initialized : Boolean;
		private var setUpNetStreamIsDirty : Boolean;
		private var streamComplete : Boolean;

		public function AkamaiLiveStream() {
			Log.write("AkamaiLiveStream * v" + Version.VERSION);
		}

		/*
		 * PUBLIC METHODS
		 */
		public function initialize(controller : IController, data : Object) : void {
			Log.write("AkamaiLiveStream.initialize");
			if (!_initialized) {
				this.controller = controller;
				controller.addEventListener(TimedPlaylistEvent.STREAM_FINISHED, update);
				skipFirstStop = controller.placement.playlistVersion == 2 ? true : false;
				mediaAnalyticsConfigUrl = controller.placement.forceHTTPS ? MEDIA_ANALYTICS_SECURE_CONFIG : MEDIA_ANALYTICS_CONFIG;
				createAudio();
				createVideo();
				if (loaderInfo) {
					loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtErrorEvent);
				}
				_initialized = true;
			}
		}

		public function run(data : Object) : void {
			Log.write("AkamaiLiveStream.run");
			if (initialized) {
				configure();
			} else {
				Log.write("AkamaiLiveStream.run::CANNOT RUN", Log.ERROR);
				throw new IllegalOperationError();
			}
		}

		public function close() : void {
			Log.write("AkamaiLiveStream.close");
			if (!initialized) {
				throw new IllegalOperationError();
			}
			// invoke a full dispose to permit garbage collection
			dispose();
		}

		public function dispose() : void {
			Log.write("AkamaiLiveStream.dispose");
			if (initialized) {
				disposePollInterval();
				disposeNetStream();
				disposeNetLoader();
				disposeStreamController();
				disposeMediaInspector();
				disposeVideo();
				disposeAudio();
				disposeController();
				playbackStarted = false;
				setUpNetStreamIsDirty = false;
				_initialized = false;
			}
		}

		public function getVideoBytesLoaded() : Number {
			return _netStream != null ? _netStream.bytesLoaded : 0;
		}

		public function getVideoBytesTotal() : Number {
			return _netStream != null ? _netStream.bytesTotal : 0;
		}

		public function getVideoStartBytes() : Number {
			return 0;
		}

		public function setPlaybackQuality(suggestedQuality : String) : void {
			Log.write("AkamaiLiveStream.setPlaybackQuality * " + suggestedQuality);
			var success : Boolean = false;
			try {
				Log.write(controller.video.metaQualities.length);
				for (var i : int = 0, j : int = controller.video.metaQualities.length; i < j; i++) {
					var metaQuality : MetaQuality = controller.video.metaQualities[i] as MetaQuality;

					if (suggestedQuality == metaQuality.quality) {
						success = true;
						// valid
						playbackQuality = suggestedQuality;
						playbackQualityIndex = i;
						controller.dispatchEvent(new PlaybackQualityEvent(PlaybackQualityEvent.CHANGE));

						if (controller.playerState == PlayerState.PLAYLIST_ENDED) {
							controller.playVideo();
						} else if (playbackStarted) {
							pauseAfterResume = controller.playerState == PlayerState.VIDEO_PAUSED ? true : false;
							timeOffset += _netStream.time;
							_netStream.close();
							streamUrl = (controller.video.metaStreams[playbackQuality] as MetaStream).uri;
							inspectMedia();
						}
						break;
					}
				}

				if (!success) {
					// invalid quality
					throw new Error();
				}
			} catch(error : Error) {
				// Log.write("AkamaiLiveStream.setPlaybackQuality * error: " + error, Log.ERROR);
				controller.error(ErrorCode.MEDIA_ERROR, "AkamaiLiveStream.setPlaybackQuality * Invalid Quality: " + suggestedQuality, true);
			}
		}

		public function playVideo() : void {
			if (controller.placement.startMuted) {
				muted = true;
			}

			streamComplete = false;
			streamUrl = (controller.video.metaStreams[playbackQuality] as MetaStream).uri;
			
			Log.write("AkamaiLiveStream.playVideo *streamUrl:" + streamUrl);

			if (controller.getPlayerState() == PlayerState.VIDEO_PAUSED) {
				Log.write("AkamaiLiveStream.playVideo  * PlayerState.VIDEO_PAUSED");
				pauseAfterResume = false;
				controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PLAYING));
				_netStream.resume();
			} else if (!playbackStarted) {
				inspectMedia();
			} else if (controller.getPlayerState() == PlayerState.AD_ENDED) {
				pauseAfterResume = false;
				controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PLAYING));
				_netStream.resume();
			}
		}

		public function pauseVideo() : void {
			Log.write("AkamaiLiveStream.pauseVideo");
			switch (controller.playerState) {
				case PlayerState.VIDEO_PLAYING :
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PAUSED));
					if (_netStream) {
						_netStream.pause();
					}
					break;
				case PlayerState.PLAYER_BUFFERING :
					pauseAfterResume = true;
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PAUSED));
					break;
			}
		}

		public function stopVideo() : void {
			Log.write("AkamaiLiveStream.stopVideo");
			clearInterval(positionIntervalId);
			positionIntervalId = undefined;
			_netStream.close();
		}

		public function seekTo(seconds : Number, allowSeekAhead : Boolean) : void {
			_netStream.seek(seconds);
		}

		public function getCurrentTime() : Number {
			return _netStream != null ? (timeOffset + _netStream.time) : 0;
		}

		public function getDuration() : Number {
			return _duration;
		}

		public function getPlaybackQuality() : String {
			return playbackQuality;
		}

		public function getPlaybackQualityIndex() : int {
			return playbackQualityIndex;
		}

		/*
		 * GETTERS/SETTERS
		 */
		public function get initialized() : Boolean {
			return _initialized;
		}

		public function get streamLatency() : Number {
			return 0;
		}

		public function get netConnection() : Object {
			return _netConnection;
		}

		public function get netStream() : Object {
			return _netStream;
		}

		public function set streamLatency(n : Number) : void {
		}

		public function get zIndex() : int {
			return Z_INDEX;
		}

		public function get loaded() : Boolean {
			return _loaded;
		}

		public function set muted(_muted : Boolean) : void {
			transformer.volume = (_muted) ? 0 : VolumeUtils.formatToCodeLevel(controller.getVolume());
			if (_netStream) {
				_netStream.soundTransform = transformer;
			}
		}

		public function set volume(_volume : Number) : void {
			transformer.volume = VolumeUtils.formatToCodeLevel(_volume);
			if (_netStream) {
				_netStream.soundTransform = transformer;
			}
		}

		public function set autoSelectQuality(b : Boolean) : void {
		}

		public function onClientData(data : Object) : void {
			switch(data.type) {
				case NetClient.METADATA:
					if (data.hasOwnProperty('duration')) {
						_duration = Number(data['duration']);
						Log.write("AkamaiLiveStream.onClientData * duration: " + _duration);
						controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.META_DATA));
					}
					break;
				case NetClient.CUEPOINT :
					Log.write("DefaultLiveMedia.onCuePoint * name=" + data.name);
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.CUE_POINT, data));
					break;
			}
		}

		/*
		 * EVENT HANDLERS
		 */
		private function onInspectComplete(event : MediaInspectorEvent) : void {
			Log.write("AkamaiLiveStream.onInspectComplete * " + event.mediaType);
			switch (event.mediaType) {
				case MediaType.AMD_LIVE:
				case MediaType.AMD_ONDEMAND:
				case MediaType.AMD_PROGRESSIVE:
				case MediaType.FMS_MBR:
				case MediaType.HDN_MBR:
				case MediaType.HDN_SBR:
					Log.write("MediaType.OTHERS" + event.mediaType);
					createNetLoader();
					netLoader.initialize(streamUrl);
					break;
				case MediaType.HDN_ADOBE_HTTP:
					Log.write("MediaType.HDN_ADOBE_HTTP" + event.mediaType);
					try {
						createStreamController();
						streamController.play(streamUrl);
					} catch(error : Error) {
						Log.write(error.toString(), Log.ERROR);
					}
					break;
			}
		}

		private function onOvpEventComplete(event : OvpEvent) : void {
			Log.write("AkamaiLiveStream.onOvpEventComplete * mediaType : " + netLoader.mediaType);
			_netConnection = netLoader.ovpConnection;
			_netStream = netLoader.netStream;

			try {
				var mediaUrl : String = controller.placement.forceHTTPS ? MEDIA_ANALYTICS_SECURE_SWF : MEDIA_ANALYTICS_SWF;
				AnalyticsPluginLoader.loadPlugin(mediaUrl, mediaAnalyticsConfigUrl);
			} catch(error : Error) {
				controller.error(ErrorCode.MEDIA_ERROR, "AkamaiLiveStream.initialize * AnalyticsPluginLoader error: " + error.message);
			}

			AnalyticsPluginLoader.setNetConnectionInfo(_netConnection, _netConnection.uri);

			createNetStream(false);
			_netStream.client = new NetClient(this);

			AnalyticsPluginLoader.setNetStreamInfo(_netStream, netLoader.streamName);

			try {
				Log.write("AkamaiLiveStream.connectedHandler * streamName: " + netLoader.streamName, Log.NET);
				_netStream.play(netLoader.streamName);
			} catch (error : Error) {
				controller.error(ErrorCode.MEDIA_ERROR, "AkamaiLiveStream.connectNetStream - " + netLoader.streamName + " - " + error.message, true);
			}
		}

		private function onAkamaiHDSEventNetStreamReady(event : AkamaiHDSEvent) : void {
			Log.write("AkamaiLiveStream.onAkamaiHDSEventNetStreamReady");
			createNetStream();
			controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.META_DATA));
		}

		private function onAkamaiHDSEventNetStreamComplete(event : AkamaiHDSEvent) : void {
			Log.write("AkamaiLiveStream.onAkamaiHDSEventNetStreamComplete");
			if (!streamComplete) {
				video.clear();
				streamComplete = true;
				controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.ENDED));
			}
		}

		private function onAkamaiHDSEventError(event : AkamaiHDSEvent) : void {
			Log.write("AkamaiLiveStream.onAkamaiHDSEventError * event: " + event.type, Log.ERROR);
			controller.error(ErrorCode.MEDIA_ERROR, "AkamaiLiveStream.onAkamaiHDSEventError * AkamaiHDSEvent.ERROR: " + event.type, true);
		}

		private function onAkamaiHDSEventIsBuffering(event : AkamaiHDSEvent) : void {
			Log.write("AkamaiLiveStream.onAkamaiHDSEventIsBuffering * event: " + streamController.isBuffering, Log.NET);
			var type : String = (streamController.isBuffering) ? MediaProviderEvent.BUFFERING : MediaProviderEvent.PLAYING;
			if (!streamComplete) {
				controller.dispatchEvent(new MediaProviderEvent(type));
			}
		}

		private function onNetStatus(event : NetStatusEvent) : void {
			if (event.info['code'] != loggedNetStatusCode) {
				loggedNetStatusCode = event.info['code'];
			}

			switch (event.info['code']) {
				case NetStreamCodes.PLAY_START :
					if (!playbackStarted) {
						playbackStarted = true;
						controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.STARTED));
					}
					if (pauseAfterResume) {
						pauseAfterResume = false;
						_netStream.pause();
						controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PAUSED));
					} else {
						controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PLAYING));
					}
					break;
				case NetStreamCodes.PAUSE_NOTIFY :
					break;
				case NetStreamCodes.PLAY_STOP :
					if (controller.getPlaylist().length == 1 && skipFirstStop) {
						skipFirstStop = false;
					} else {
						if (!streamComplete) {
							video.clear();
							streamComplete = true;
							controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.ENDED));
						}
					}
					break;
				case NetStreamCodes.BUFFER_EMPTY :
					break;
				case NetStreamCodes.PLAY_UNPUBLISH_NOTIFY :
					break;
			}

			if (streamController) {
				Log.write("streamController.effectiveBitrate: " + Math.round(streamController.effectiveBitrate), Log.NET);
				Log.write("streamController.startingBitrate: " + (!isNaN(streamController.startingBitrate)) ? streamController.startingBitrate : -1, Log.NET);
				Log.write("streamController.averageBandwidth: " + streamController.averageBandwidth, Log.NET);
			}
		}

		private function onInspectError(event : MediaInspectorEvent) : void {
			handleError(ErrorCode.MEDIA_ERROR, "AkamaiLiveStream.onInspectError * " + event.data, true);
		}

		private function onOvpEventError(event : OvpEvent) : void {
			controller.video.playbackAuthorised = false;
			handleError(ErrorCode.MEDIA_ERROR, "AkamaiLiveStream.onOvpEventError * " + event.data['errorDescription'] + " * url: " + streamUrl, true);
		}

		private function onError(event : Event) : void {
			handleError(ErrorCode.MEDIA_ERROR, "AkamaiLiveStream.onError * " + event.toString(), true);
		}

		private function handleError(errorCode : String, errorMessage : String, blocking : Boolean = false) : void {
			controller.error(errorCode, errorMessage, blocking);
			if (netLoader) {
				var errorObj : Object = {code:errorCode, description:errorMessage};
				AnalyticsPluginLoader.handleError(errorObj);
			}
		}

		/*
		 * PRIVATE METHODS
		 */
		private function update(evt : TimedPlaylistEvent) : void {
			if (controller.placement.playlistVersion == 2) {
				controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.ENDED));
			}
		}

		private function inspectMedia() : void {
			Log.write("AkamaiLiveStream.inspectMedia");
			createPollInterval();
			createMediaInspector();
			mediaInspector.inspect(streamUrl);
			controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.BUFFERING));
		}

		private function pollPosition() : void {
			try {
				if (_netStream && _netStream.info.playbackBytesPerSecond) {
					var bitrate : uint = (controller.video.metaStreams[playbackQuality] as MetaStream).bitrate;
					bitrate = Math.ceil(bitrate + (_netStream.info.playbackBytesPerSecond / 1024 * 8)) / 2;
					(controller.video.metaStreams[playbackQuality] as MetaStream).bitrate = bitrate;
				}
			} catch(error : Error) {
				// Log.write("AkamaiLiveStream.pollPosition ", error.message);
			}
		}

		private function configure() : void {
			// any pre configuration to be performed
		}

		private function createPollInterval() : void {
			disposePollInterval();
			positionIntervalId = setInterval(pollPosition, 1000);
		}

		private function disposePollInterval() : void {
			if (positionIntervalId) {
				clearInterval(positionIntervalId);
			}
			positionIntervalId = undefined;
		}

		private function createVideo() : void {
			video = new Video();
			controller.addVideoScreen(video);
		}

		private function disposeVideo() : void {
			Log.write("AkamaiLiveStream.disposeVideo");
			try {
				// remove children
				controller.removeVideoScreen(video);
			} catch(error : Error) {
				Log.write("AkamaiLiveStream.disposeChildren * error: " + error);
			}

			video.attachNetStream(null);
			video = null;
		}

		private function createAudio() : void {
			transformer = new SoundTransform();
		}

		private function disposeAudio() : void {
			Log.write("AkamaiLiveStream.disposeAudio");
			transformer = null;
		}

		private function createMediaInspector() : void {
			if (!mediaInspector) {
				Log.write("AkamaiLiveStream.createMediaInspector");
				mediaInspector = new MediaInspector();
				mediaInspector.addEventListener(MediaInspectorEvent.COMPLETE, onInspectComplete);
				mediaInspector.addEventListener(MediaInspectorEvent.ERROR, onInspectError);
				mediaInspector.addEventListener(MediaInspectorEvent.TIMEOUT, onInspectError);
			} else {
				Log.write("AkamaiLiveStream.createMediaInspector * ALREADY CREATED");
			}
		}

		private function disposeMediaInspector() : void {
			Log.write("AkamaiLiveStream.disposeMediaInspector");
			if (mediaInspector) {
				mediaInspector.removeEventListener(MediaInspectorEvent.COMPLETE, onInspectComplete);
				mediaInspector.removeEventListener(MediaInspectorEvent.ERROR, onInspectError);
				mediaInspector.removeEventListener(MediaInspectorEvent.TIMEOUT, onInspectError);
				mediaInspector = null;
			}
		}

		private function createStreamController() : void {
			if (!streamController) {
				Log.write("AkamaiLiveStream.createStreamController");
				streamController = new AkamaiStreamController();
				streamController.addEventListener(AkamaiHDSEvent.NETSTREAM_READY, onAkamaiHDSEventNetStreamReady);
				streamController.addEventListener(AkamaiHDSEvent.COMPLETE, onAkamaiHDSEventNetStreamComplete);
				streamController.addEventListener(AkamaiHDSEvent.ERROR, onAkamaiHDSEventError);
				streamController.addEventListener(AkamaiHDSEvent.IS_BUFFERING, onAkamaiHDSEventIsBuffering);

				if (controller.config.DEFAULT_STARTING_BITRATE > 0) {
					streamController.startingBitrate = controller.config.DEFAULT_STARTING_BITRATE;
				}
			} else {
				Log.write("AkamaiLiveStream.createStreamController * ALREADY CREATED");
			}
		}

		private function disposeStreamController() : void {
			Log.write("AkamaiLiveStream.disposeStreamController");
			if (streamController) {
				streamController.removeEventListener(AkamaiHDSEvent.NETSTREAM_READY, onAkamaiHDSEventNetStreamReady);
				streamController.removeEventListener(AkamaiHDSEvent.COMPLETE, onAkamaiHDSEventNetStreamComplete);
				streamController.removeEventListener(AkamaiHDSEvent.ERROR, onAkamaiHDSEventError);
				streamController.removeEventListener(AkamaiHDSEvent.IS_BUFFERING, onAkamaiHDSEventIsBuffering);

				streamController.unloadMedia();
				streamController.closeAndDestroy();
				streamController = null;
			}
		}

		private function createNetLoader() : void {
			if (!netLoader) {
				Log.write("AkamaiLiveStream.createNetLoader");
				netLoader = new AkamaiNetLoader();
				netLoader.addEventListener(OvpEvent.COMPLETE, onOvpEventComplete);
				netLoader.addEventListener(OvpEvent.ERROR, onOvpEventError);
			} else {
				Log.write("AkamaiLiveStream.createNetLoader * ALREADY CREATED");
			}
		}

		private function disposeNetLoader() : void {
			Log.write("AkamaiLiveStream.disposeNetLoader");
			if (netLoader) {
				netLoader.removeEventListener(OvpEvent.COMPLETE, onOvpEventComplete);
				netLoader.removeEventListener(OvpEvent.ERROR, onOvpEventError);
				netLoader = null;
			}
		}

		private function createNetStream(usingHds : Boolean = true) : void {
			Log.write("AkamaiLiveStream.createNetStream ");
			if (!setUpNetStreamIsDirty) {
				setUpNetStreamIsDirty = true;

				if (usingHds) {
					streamController.analyticsBeacon = mediaAnalyticsConfigUrl;
					_netStream = streamController.netStream;
				}

				_netStream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_netStream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
				_netStream.addEventListener(IOErrorEvent.IO_ERROR, onError);

				_netStream.bufferTime = controller.config.BUFFER_TIME;
				_netStream.soundTransform = transformer;

				video.smoothing = true;
				video.attachNetStream(_netStream);

				// NetStream object initialized
				controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.NS_INITIALIZED));

				if (usingHds) {
					_duration = streamController.duration;
				}
			}
		}

		private function disposeNetStream() : void {
			Log.write("AkamaiLiveStream.disposeNetStream");
			if (_netStream) {
				Log.write("AkamaiLiveStream.disposeNetStream * CAN DISPOSE");
				_netStream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_netStream.removeEventListener(IOErrorEvent.IO_ERROR, onError);
				_netStream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, onError);
				_netStream.soundTransform = null;
				_netStream.close();
				_netStream.dispose();
				_netStream = null;
			}
		}

		private function disposeController() : void {
			controller.removeEventListener(TimedPlaylistEvent.STREAM_FINISHED, update);
			controller = null;
		}

		private function handleUncaughtErrorEvent(event : UncaughtErrorEvent) : void {
			event.preventDefault();
			Log.write('AkamaiLiveStream.handleUncaughtErrorEvent', Log.ERROR);
		}
	}
}
