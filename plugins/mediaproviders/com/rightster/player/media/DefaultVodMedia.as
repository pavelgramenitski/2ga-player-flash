package com.rightster.player.media {
	import com.rightster.utils.VolumeUtils;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.PlayerState;
	import com.rightster.utils.Log;

	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.NetStatusEvent;
	import flash.media.SoundTransform;
	import flash.media.Video;
	import flash.net.NetConnection;
	import flash.net.NetStream;
	import flash.utils.*;

	/*
	 * @author Daniel
	 */
	public class DefaultVodMedia extends BaseMediaProvider {
		private static const VERSION : String = "2.28.2";
		private static const BITRATE : Array = [400, 800, 1200];
		private var controller : IController;
		private var keyframes : Object;
		private var timeOffset : Number;
		private var _positionInterval : uint;
		private var _bandwidthTimeout : Number;
		private var _bandwidthChecked : Boolean;
		private var _bandwidthDelay : Number = 1000;
		private var _bandwidth : Array;
		private var _framerate : Number = 30;
		private var _framedropChecked : Boolean;
		private var _framedropTimeout : uint;
		private var _droppedFrames : Array;
		private var _autoSwitch : Boolean = false;
		private var _useFastStartBuffer : Boolean;
		private var _startparam : String;

		public function DefaultVodMedia() : void {
			super();
			Log.write("DefaultVodMedia * v" + VERSION);
		}

		override public function initialize(controller : IController, data : Object) : void {
			Log.write("DefaultVodMedia.initialize");

			_duration = 0;
			timeOffset = 0;
			_loaded = true;
			playbackStarted = false;

			this.controller = controller;

			if (controller.video.qualities.length == 3) {
				playbackQuality = controller.video.qualities[controller.video.qualities.length - 2];
			} else {
				playbackQuality = controller.video.qualities[controller.video.qualities.length - 1];
			}

			_connection = new NetConnection();
			_connection.connect(null);

			_autoSwitch = controller.placement.autoBitrateSwitching;
			_useFastStartBuffer = _autoSwitch;
			_stream = new NetStream(_connection);
			_stream.bufferTime = _useFastStartBuffer ? controller.config.FAST_START_BUFFER_TIME : controller.config.BUFFER_TIME;
			_stream.soundTransform = new SoundTransform(VolumeUtils.formatToCodeLevel(controller.getVolume()));
			_stream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			_stream.client = new NetClient(this);

			transformer = new SoundTransform();

			video = new Video();
			video.smoothing = true;
			video.attachNetStream(_stream);

			controller.addVideoScreen(video);
		}

		override public function dispose() : void {
			if (_stream != null) {
				_stream.removeEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
				_stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				_stream.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_stream.close();
			}

			if (_connection != null) _connection.close();
			if (video.parent != null) video.parent.removeChild(video);

			_bandwidthChecked = false;
			_duration = 0;
			_stream = null;
			_connection = null;
			controller = null;
		}

		override public function playVideo() : void {
			Log.write("DefaultVodMedia.playVideo * state : " + controller.playerState);

			if (controller.placement.startMuted) {
				muted = true;
			}

			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.VIDEO_CUED :
				case PlayerState.AD_ENDED :
					if (!controller.placement.forceadBreak) {
						loadVideo();
					} else {
						pauseAfterResume = false;
						controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PLAYING));
						_stream.resume();
						controller.placement.forceadBreak = false;
					}
					break;
				case PlayerState.PLAYLIST_ENDED :
					controller.playVideo();
					break;
				case PlayerState.VIDEO_PAUSED :
				default :
					pauseAfterResume = false;
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PLAYING));
					_stream.resume();
					break;
			}
		}

		override public function pauseVideo() : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_PLAYING :
					_stream.pause();
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PAUSED));
					break;
				case PlayerState.PLAYER_BUFFERING :
					pauseAfterResume = true;
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PAUSED));
					break;
			}
		}

		override public function stopVideo() : void {
			_stream.close();
			playbackEnded = true;
			_bandwidthChecked = false;
			clearInterval(_positionInterval);
			_positionInterval = undefined;
			clearTimeout(_framedropTimeout);
			_framedropTimeout = undefined;

			controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.ENDED));
		}

		override public function seekTo(seconds : Number, allowSeekAhead : Boolean) : void {
			if (controller.playerState != PlayerState.PLAYER_ERROR) {
				var offset : Number = getOffset(seconds, true);
				var maxCachedTime : Number = (getVideoBytesLoaded() / getVideoBytesTotal()) * (_duration - timeOffset) + timeOffset;
				Log.write("DefaultVodMedia.seekTo * resquested : " + seconds + ", seeking to : " + offset);
				pauseAfterResume = controller.playerState == PlayerState.VIDEO_PAUSED ? true : false;

				if (_startparam) {
					if (offset > timeOffset && offset < maxCachedTime) {
						_stream.seek(offset - timeOffset);
					} else {
						clearInterval(_positionInterval);
						_positionInterval = undefined;
						loadVideo(offset);
					}
				} else {
					_stream.seek(offset - timeOffset);
				}
			}
		}

		override public function set muted(_muted : Boolean) : void {
			Log.write("DefaultVodMedia.set Mute" + _muted);
			transformer.volume = (_muted) ? 0 : VolumeUtils.formatToCodeLevel(controller.getVolume());
			if (_stream) {
				_stream.soundTransform = transformer;
			}
		}

		override public function set volume(_volume : Number) : void {
			transformer.volume = VolumeUtils.formatToCodeLevel(_volume);
			if (_stream) {
				_stream.soundTransform = transformer;
			}
		}

		override public function set autoSelectQuality(b : Boolean) : void {
			Log.write("DefaultVodMedia.autoSelectQuality : " + b);
			_autoSwitch = _useFastStartBuffer = b;
			controller.dispatchEvent(new PlaybackQualityEvent(PlaybackQualityEvent.CHANGE));
		}

		override public function getCurrentTime() : Number {
			return _stream != null ? (timeOffset + _stream.time) : 0;
		}

		override public function getPlaybackQuality() : String {
			return playbackQuality;
		}

		override public function setPlaybackQuality(suggestedQuality : String) : void {
			for (var i : int = 0; i < controller.video.qualities.length; i++) {
				if (suggestedQuality == controller.video.qualities[i]) {
					// suggestedQuality is valid
					playbackQuality = suggestedQuality;
					playbackQualityIndex = i;
					controller.dispatchEvent(new PlaybackQualityEvent(PlaybackQualityEvent.CHANGE));

					if (controller.playerState == PlayerState.PLAYLIST_ENDED) {
						controller.playVideo();
					} else if (playbackStarted) {
						pauseAfterResume = controller.playerState == PlayerState.VIDEO_PAUSED ? true : false;

						var offset : Number = getOffset(getCurrentTime(), true);
						loadVideo(offset);
					}
					break;
				}
			}
		}

		private function loadVideo(offset : Number = 0) : void {
			streamUrl = (controller.video.metaStreams[playbackQuality]  as MetaStream).uri;
			if (controller.placement.forceHTTPS) {
				streamUrl = streamUrl.replace("http:", "https:");
			}
			var cdn : String = (controller.video.metaStreams[playbackQuality]  as MetaStream).cdn;

			_startparam = StartParam.getStartValue(cdn);

			if (_startparam) {
				timeOffset = offset;
				streamUrl = getURLConcat(streamUrl, _startparam, offset);
			}

			if (controller.placement.authValue != "") {
				streamUrl = getURLConcat(streamUrl, "auth", controller.placement.authValue);
			}

			playbackEnded = false;

			controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.BUFFERING));

			clearInterval(_positionInterval);
			_positionInterval = setInterval(positionInterval, 100);

			_bandwidth = new Array();
			_droppedFrames = new Array();

			try {
				Log.write("DefaultVodMedia.loadVideo * streamUrl: " + streamUrl, Log.NET);
				if (streamUrl == null || streamUrl == "") {
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultVodMedia.starloadVideotPlayback * url is null: " + streamUrl, true);
				} else {
					_stream.bufferTime = _useFastStartBuffer ? controller.config.FAST_START_BUFFER_TIME : controller.config.BUFFER_TIME;
					_stream.play(streamUrl);
				}
			} catch (err : Error) {
				controller.error(ErrorCode.MEDIA_ERROR, "DefaultVodMedia.starloadVideotPlayback * " + err.message + " * url: " + streamUrl, true);
			}
		}

		public function onClientData(data : Object) : void {
			Log.write("DefaultLiveMedia.onClientData * type : " + data.type);

			if (data.type == NetClient.METADATA) {
				if (_duration <= 0) {
					if (data.hasOwnProperty('seekpoints')) {
						keyframes = convertSeekpoints(data['seekpoints']);
					} else if (data.hasOwnProperty('keyframes')) {
						keyframes = data['keyframes'];
					}
					if (data.hasOwnProperty('duration')) {
						_duration = Number(data['duration']);
						Log.write("DefaultVodMedia.onMetaData * duration: " + _duration);
					}
					if (data.hasOwnProperty('videoframerate')) {
						_framerate = Number(data.videoframerate);
					}
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.META_DATA));
				}
				var bitrate : Number = Math.ceil(_stream.bytesTotal / 1024 * 8 / _duration);
				(controller.video.metaStreams[playbackQuality] as MetaStream).bitrate = bitrate;
			}
		}

		private function checkBandwidth(lastLoaded : Number) : void {
			var currentLoaded : Number = _stream.bytesLoaded;
			var bandwidth : Number = Math.ceil((currentLoaded - lastLoaded) / 1024) * 8 / (_bandwidthDelay / 1000);
			// Log.write("currentLoaded=" + currentLoaded + ", bytesTotal=" + _stream.bytesTotal + ", bandwidth=" + bandwidth, Log.NORMAL);
			if (currentLoaded < _stream.bytesTotal) {
				Log.write("bandwidth=" + bandwidth, Log.NORMAL);
				_bandwidth.push(bandwidth);
				var qualities : Array = controller.video.qualities;
				var avg : Number = getAvgBandwidth(_bandwidth);
				Log.write("avg bw=" + avg, Log.NORMAL);
				if (_autoSwitch && avg >= 0 && playbackQualityIndex < qualities.length - 1 && avg > BITRATE[playbackQualityIndex] * 1.5) {
					for (var i : int = qualities.length - 1; i > playbackQualityIndex; i--) {
						if (avg > BITRATE[i] * 1.1) {
							Log.write("SwitchUp");
							setPlaybackQuality(controller.video.qualities[i]);
						}
					}
				}
				_bandwidthChecked = false;
				clearTimeout(_bandwidthTimeout);
				_bandwidthTimeout = setTimeout(checkBandwidth, _bandwidthDelay, _stream.bytesLoaded);
			}
		}

		private function checkFramedrop() : void {
			_droppedFrames.push(_stream.info.droppedFrames);

			var len : Number = _droppedFrames.length;
			if (len > 5 && controller.playerState == PlayerState.VIDEO_PLAYING) {
				var drp : Number = (_droppedFrames[len - 1] - _droppedFrames[len - 6]) / 5;
				Log.write("_droppedFrames : " + drp);
			}
			_framedropChecked = false;
			clearTimeout(_framedropTimeout);
			_framedropTimeout = setTimeout(checkFramedrop, 1000);
		}

		private function positionInterval() : void {
			if (_useFastStartBuffer && _stream && _stream.bufferLength > _stream.bufferTime) {
				_stream.bufferTime = _stream.bufferLength;
			}
			if (!_bandwidthChecked && _stream && _stream.bytesLoaded > 0 && _stream.bytesLoaded < _stream.bytesTotal) {
				_bandwidthChecked = true;
				_bandwidthTimeout = setTimeout(checkBandwidth, _bandwidthDelay, _stream.bytesLoaded);
			}
			if (!_framedropChecked && !playbackEnded) {
				_framedropChecked = true;
				clearTimeout(_framedropTimeout);
				_framedropTimeout = setTimeout(checkFramedrop, 1000);
			}
		}

		private function netStatusHandler(event : NetStatusEvent) : void {
			Log.write("DefaultVodMedia.netStatusHandler * ", event.info['code']);

			switch (event.info['code']) {
				case NetStreamCodes.PLAY_START :
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.BUFFERING));
					break;
				case NetStreamCodes.SEEK_NOTIFY :
					if (playbackEnded) {
						playbackEnded = false;
					}
					break;
				case NetStreamCodes.BUFFER_FULL :
					if (!playbackEnded) {
						if (!playbackStarted) {
							playbackStarted = true;
							controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.STARTED));
						}
						if (pauseAfterResume) {
							pauseAfterResume = false;
							_stream.pause();
							controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PAUSED));
						} else {
							controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PLAYING));
						}
					}
					break;
				case NetStreamCodes.BUFFER_EMPTY :
					if (!playbackEnded) {
						controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.BUFFERING));
					}
					if (_useFastStartBuffer) {
						_stream.bufferTime = _useFastStartBuffer ? controller.config.FAST_START_BUFFER_TIME : controller.config.BUFFER_TIME;
					}
					var avg : Number = getAvgBandwidth(_bandwidth);
					Log.write("Empty Buffer Ocurred idx=" + playbackQualityIndex + "avg bw=" + avg);
					if (_autoSwitch && avg >= 0 && playbackQualityIndex > 0 && avg < BITRATE[playbackQualityIndex]) {
						Log.write("SwitchDown, Look for appropriate quality");
						for (var i : int = playbackQualityIndex - 1; i > 0; i--) {
							if (avg > BITRATE[i] * 1.1) {
								break;
							}
						}
						Log.write("SwitchDown to=" + i);
						setPlaybackQuality(controller.video.qualities[i]);
					}
					break;
				case NetStreamCodes.PLAY_STOP :
					playbackEnded = true;
					stopVideo();
					break;
				case NetStreamCodes.SEEK_INVALIDTIME :
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.BUFFERING));
					break;
				case NetStreamCodes.PLAY_STREAMNOTFOUND :
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultVodMedia.netStatusHandler * NETSTREAM_NOT_FOUND * url: " + streamUrl, true);
					break;
				case NetStreamCodes.PLAY_FILESTRUCTUREINVALID :
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultVodMedia.netStatusHandler * NETSTREAM_FILE_STRUCTURE_INVALID * url: " + streamUrl, true);
					break;
				case NetStreamCodes.PLAY_NOSUPPORTEDTRACKFOUND :
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultVodMedia.netStatusHandler * NETSTREAM_NO_SUPPORTED_TRACK * url: " + streamUrl, true);
					break;
			}
		}

		private function getOffset(pos : Number, tme : Boolean = false) : Number {
			if (!keyframes) {
				return 0;
			}
			for (var i : Number = 0; i < keyframes['times'].length - 1; i++) {
				if (keyframes['times'][i] <= pos && keyframes['times'][i + 1] >= pos) {
					break;
				}
			}

			if (tme == true) {
				if (i < keyframes['times'].length - 1) {
					return (keyframes['times'][i + 1] - pos > pos - keyframes['times'][i]) ? keyframes['times'][i] : keyframes['times'][i + 1];
				} else {
					return keyframes['times'][i];
				}
			} else {
				return keyframes['positions'][i];
			}
		}

		private function getURLConcat(url : String, prm : String, val : *) : String {
			if (url.indexOf('?') > -1) {
				return url + '&' + prm + '=' + val;
			} else {
				return url + '?' + prm + '=' + val;
			}
		}

		private function errorHandler(e : Event) : void {
			controller.error(ErrorCode.MEDIA_ERROR, "DefaultVodMedia.errorHandler * " + e['text'] + " * url: " + streamUrl, true);
		}
	}
}