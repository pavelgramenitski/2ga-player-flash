package com.rightster.player.media {
	import com.rightster.utils.VolumeUtils;
	import com.rightster.player.events.TimedPlaylistEvent;
	import com.rightster.player.events.PlaybackQualityEvent;
	import flash.utils.setTimeout;
	import flash.events.AsyncErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.net.ObjectEncoding;
	import flash.events.NetStatusEvent;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.PlayerState;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.media.SoundTransform;
	import flash.net.NetStream;
	import flash.net.NetConnection;
	import flash.media.Video;
	import com.rightster.utils.Log;

	import com.rightster.player.controller.IController;

	/**
	 * @author Rightster
	 */
	public class DefaultLiveMedia extends BaseMediaProvider {
		
		private static const VERSION : String = "2.28.2";
		private static const SUPPORTED_PROTOCOLS : Array = ['rtmp', 'rtmpe', 'rtmpt', 'rtmpte'];
		
		private const MAX_SUBSCRIBE_RETRY : uint = 5;
		private const SUBSCRIBE_TIMER : Number = 1000;
		private const LATENCY_TIMER : Number = 1000;
		private const FC_SUBSCRIBE : String = "FCSubscribe";
		
		private var controller : IController;
		private var protocol : String;
		private var connectCommand : String;
		private var streamName : String;
		private var lastConnectionKey : String;
		
		private var subscribeRetry : uint = 0;
		private var subscribeTimer : Timer;
		private var timeOffset : Number = 0;
		
		private var latencyTimer : Timer;
		private var latency : Number = 0;
		
		public function DefaultLiveMedia() {
			Log.write("DefaultLiveMedia * v" + VERSION);
		}

		override public function setPlaybackQuality(suggestedQuality : String) : void {
			Log.write("DefaultLiveMedia.setPlaybackQuality * " + suggestedQuality);
			
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
						timeOffset += _stream.time;
						_stream.close();
						parseSource();
						connect();
					}
					break;
				}
			}
		}

		override public function initialize(controller : IController, data : Object) : void {
			this.controller = controller;
			//set the top quality
			if (controller.video.qualities.length == 3) {
				playbackQuality = controller.video.qualities[controller.video.qualities.length - 2];
			} else {
				playbackQuality = controller.video.qualities[controller.video.qualities.length - 1];
			}
			
			subscribeTimer = new Timer(SUBSCRIBE_TIMER, 1);
			subscribeTimer.addEventListener(TimerEvent.TIMER_COMPLETE, callFCSubscribe);
			
			latencyTimer = new Timer(LATENCY_TIMER);
			latencyTimer.addEventListener(TimerEvent.TIMER, onLatencyTimer);
			
			transformer = new SoundTransform();
			
			video = new Video();
			controller.addVideoScreen(video);
			
			controller.addEventListener(TimedPlaylistEvent.STREAM_FINISHED, update);
		}
		
		private function update(evt : TimedPlaylistEvent) : void {
			if(controller.placement.playlistVersion == 2){
				controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.ENDED));
			}
		}

		override public function dispose() : void {
			if(_stream != null){
				_stream.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_stream.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				_stream.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_stream.close();
			}
			
			if(_connection != null){
				_connection.removeEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_connection.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_connection.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				_connection.close();
			}
			
			if(latencyTimer != null){
				latencyTimer.stop();
				latencyTimer.removeEventListener(TimerEvent.TIMER, onLatencyTimer);
				latencyTimer = null;
			}
			
			if(subscribeTimer != null){
				subscribeTimer.stop();
				subscribeTimer.removeEventListener(TimerEvent.TIMER_COMPLETE, callFCSubscribe);
			}
			
			if (video.parent != null) video.parent.removeChild(video);
			
			if(controller != null) controller.removeEventListener(TimedPlaylistEvent.STREAM_FINISHED, update);
			
			subscribeTimer = null;
			_stream = null;
			_connection = null;
			controller = null;
		}

		override public function playVideo() : void {
			Log.write("DefaultLiveMedia.playVideo");
			parseSource();
				
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.VIDEO_CUED :
				case PlayerState.AD_ENDED :
					if (controller.placement.playbackAuthorisation && !controller.video.playbackAuthorised) {
						Log.write("DefaultLiveMedia.playVideo  * NOT AUTHORISED", Log.TRACKING);
						controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.REQUEST_AUTHORISATION));
					}else{
						connect();
					}
					
				break;
				
				case PlayerState.VIDEO_PAUSED :	
					pauseAfterResume = false;				
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PLAYING));
					_stream.resume();
				break;
			}
		}

		override public function pauseVideo() : void {
			Log.write("DefaultLiveMedia.pauseVideo");
			
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
			Log.write("DefaultLiveMedia.stopVideo");
			
			_stream.close();
			subscribeTimer.stop();
		}

		override public function getCurrentTime() : Number {
			return _stream != null ? (timeOffset + _stream.time) : 0;
		}

		override public function set muted(_muted : Boolean) : void {
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
		
		public function onClientData(data : Object):void {
			Log.write("DefaultLiveMedia.onClientData * type : " + data.type);
			
			switch(data.type) {
				case NetClient.FCSUBSCRIBE:
					Log.write("DefaultLiveMedia.onClientData * code : " + data.code + ", description : " + data.description);
					if (data.code == NetStreamCodes.PLAY_START) {
						connectedHandler();
					}
					else if (data.code == NetStreamCodes.PLAY_STREAMNOTFOUND) {
						subscribeTimer.start();
					}
				break;
				
				case NetClient.METADATA:
					if (data.hasOwnProperty('duration')) {
						_duration = Number(data['duration']);
						Log.write("DefaultLiveMedia.onClientData * duration: " + _duration);
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
		 * private methods
		 */
		private function callFCSubscribe() : void {
			Log.write("DefaultLiveMedia.callFCSubscribe * connected to : " + _connection.uri + ", streamName : " + streamName + ", subscribeRetry: " + subscribeRetry);
			if (++subscribeRetry <= MAX_SUBSCRIBE_RETRY) {
				if(controller.playerState != PlayerState.PLAYER_ERROR){
					_connection.call(FC_SUBSCRIBE, null, streamName);
				}
			} else {
				controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.callFCSubscribe - " + streamName + " - stream not found", true);
			}	
		}
		
		private function parseSource() : void {
			streamUrl = (controller.video.metaStreams[playbackQuality] as MetaStream).uri;
			protocol = streamUrl.substr(0,streamUrl.indexOf(':'));
			
			if (SUPPORTED_PROTOCOLS.indexOf(protocol) != -1) {
				connectCommand = streamUrl.substr(streamUrl.indexOf('://')+3, streamUrl.lastIndexOf('/')-7);
				streamName =  streamUrl.substr(streamUrl.lastIndexOf('/') + 1,streamUrl.length - 1);
			} else {
				controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.parseSource * protocol error", true);
			}
			Log.write("DefaultLiveMedia.parseSource  * protocol: " + protocol + ", connectCommand: " + connectCommand + ", streamName: " + streamName, Log.NET);
		}
		
		private function connect() : void {	
			subscribeRetry = 0;			
			if (connectCommand == lastConnectionKey && _connection.connected) {
				callFCSubscribe();
			}
			else {
				_connection = new NetConnection();
				_connection.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
				_connection.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				_connection.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
				_connection.objectEncoding = ObjectEncoding.AMF0;
				_connection.client = new NetClient(this);
					
				try {
					_connection.connect(protocol + '://' + connectCommand);
				} catch (error : Error) {
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.connect - " + connectCommand + " - " + error.message, true);
				}
				lastConnectionKey = connectCommand;
			}
			
			controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.BUFFERING));
		}
		
		private function connectedHandler() : void {	
			Log.write("DefaultLiveMedia.connectedHandler * " + streamName);
			
			if (_stream) {
				_stream.close();
				_stream = null;
			}
			
			_stream = new NetStream(_connection);
			_stream.addEventListener(NetStatusEvent.NET_STATUS, onNetStatus);
			_stream.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			_stream.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			
			_stream.bufferTime = controller.config.BUFFER_TIME;
			_stream.checkPolicyFile = true;
			_stream.soundTransform = transformer;
			_stream.client = new NetClient(this);
			
			changeLatency(controller.video.defaultStreamLatency);
			latencyTimer.start();
			
			video.smoothing = true;
			video.attachNetStream(_stream);
					
			try {
				_stream.play(streamName);
			} catch (error : Error) {
				controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.connectNetStream - " + streamName + " - " + error.message, true);
			}
		}
		
		private function onNetStatus(event:NetStatusEvent) : void {
			Log.write("DefaultLiveMedia.onNetStatus ", event.info['code']);
			
			switch (event.info['code']) {
				case NetConnectionCodes.CONNECT_SUCCESS :
					callFCSubscribe();
					break;
				case NetConnectionCodes.CONNECT_REJECTED :
					if(event.info.ex.code == 302) {
						connectCommand = event.info.ex.redirect;
						setTimeout(connect, 100);
					}
					break;
				case NetStreamCodes.PLAY_START : 
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
					break;
				case NetStreamCodes.PAUSE_NOTIFY :
					controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.PAUSED));
					break;
				case NetStreamCodes.PLAY_STREAMNOTFOUND :
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.onNetStatus * NETSTREAM_NOT_FOUND * url: " + streamUrl, true);
					break;
				case NetStreamCodes.PLAY_FILESTRUCTUREINVALID :
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.onNetStatus * NETSTREAM_FILE_STRUCTURE_INVALID * url: " + streamUrl, true);
					break;
				case NetStreamCodes.PLAY_NOSUPPORTEDTRACKFOUND :
					controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.onNetStatus * NETSTREAM_NO_SUPPORTED_TRACK * url: " + streamUrl, true);
					break;
				case NetStreamCodes.PLAY_STOP :
					video.clear(); 
					///controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.ENDED));
				break;
			}
		}
		
		private function errorHandler(e : Event) : void {			
			controller.error(ErrorCode.MEDIA_ERROR, "DefaultLiveMedia.errorHandler * " + e['text'] + " * url: " + streamUrl, true);
		}
		
		private function onLatencyTimer(event:TimerEvent) : void {
			if (_stream && _stream.info.playbackBytesPerSecond) {
				var bitrate : uint = (controller.video.metaStreams[playbackQuality] as MetaStream).bitrate;
				 bitrate = Math.ceil(bitrate + (_stream.info.playbackBytesPerSecond / 1024 * 8)) / 2;
				 (controller.video.metaStreams[playbackQuality] as MetaStream).bitrate = bitrate;
			}
			if (_stream && _stream.bufferLength < latency && playbackStarted) {
				_stream.pause();
				_stream.resume();
				playbackStarted = false;
				Log.write("DefaultLiveMedia.onLatencyTimer * PAUSED (bufferLength=" + _stream.bufferLength + " < latency=" + latency);
				controller.dispatchEvent(new MediaProviderEvent(MediaProviderEvent.BUFFERING));
			}
		}
		
		private function changeLatency(n : Number) : void {
			latency = n;
			Log.write("DefaultLiveMedia.changeLatency * latency: " + n);
			if (_stream != null) {
				_stream.bufferTime = latency + controller.config.BUFFER_TIME;
				_stream.pause();
				_stream.resume();
			}
		}
	}
}
