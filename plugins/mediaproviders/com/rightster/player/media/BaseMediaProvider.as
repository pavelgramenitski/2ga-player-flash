package com.rightster.player.media {
	import flash.media.Video;
	import flash.media.SoundTransform;
	import flash.net.NetStream;
	import flash.net.NetConnection;
	import com.rightster.player.model.PluginZindex;
	import flash.display.MovieClip;

	import com.rightster.player.model.IPlugin;
	import com.rightster.player.media.IMediaProvider;
	import com.rightster.player.controller.IController;

	/**
	 * @author Ravi Thapa
	 */
	public class BaseMediaProvider extends MovieClip implements IPlugin, IMediaProvider {
		private static const Z_INDEX : int = PluginZindex.NONE;
		
		public var _connection : NetConnection;
		public var _stream : NetStream;
		public var transformer:SoundTransform;
		public var video : Video;
		
		public var _loaded : Boolean = true;
		public var streamUrl : String;
		public var _duration : Number;
		public var playbackQuality : String = "";
		public var playbackQualityIndex : int;
		public var playbackStarted : Boolean;
		public var playbackEnded : Boolean;
		public var pauseAfterResume : Boolean;
		
		private var _initialized : Boolean;
		
		public function BaseMediaProvider() {
		}

		public function getVideoBytesLoaded() : Number {
			return _stream != null ? _stream.bytesLoaded : 0;
		}

		public function getVideoBytesTotal() : Number {
			return _stream != null ? _stream.bytesTotal : 0;
		}

		public function getVideoStartBytes() : Number {
			return 0;
		}

		public function setPlaybackQuality(suggestedQuality : String) : void {
		}

		public function getPlaybackQuality() : String {
			return playbackQuality;
		}

		public function getPlaybackQualityIndex() : int {
			return playbackQualityIndex;
		}

		public function get streamLatency() : Number {
			// TODO: Auto-generated method stub
			return 0;
		}

		public function get netConnection() : Object {
			return _connection;
		}

		public function get netStream() : Object {
			return _stream;
		}

		public function set streamLatency(n : Number) : void {
		}

		public function set autoSelectQuality(b : Boolean) : void {
		}

		public function playVideo() : void {
		}

		public function pauseVideo() : void {
		}

		public function stopVideo() : void {
		}

		public function seekTo(seconds : Number, allowSeekAhead : Boolean) : void {
		}

		public function getCurrentTime() : Number {
			// TODO: Auto-generated method stub
			return 0;
		}

		public function getDuration() : Number {
			return _duration;
		}
		
		public function run(data : Object) : void{
			
		}

		public function close() : void{
			
		}
		

		public function dispose() : void {
		}

		public function set muted(b : Boolean) : void {
		}

		public function set volume(n : Number) : void {
		}

		public function initialize(controller : IController, data : Object) : void {
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
		
		
		public function getAvgBandwidth(bandwidth : Array) : int {
			var BANDWIDTH_SAMPLE_RATE : uint = 10;
			var avg:int = -1;
			if (bandwidth.length >= BANDWIDTH_SAMPLE_RATE) {
				var sampleArr : Array = bandwidth.slice(bandwidth.length-(BANDWIDTH_SAMPLE_RATE), bandwidth.length);
				var sum : int = 0;
				for (var i:int=0; i<sampleArr.length; i++) sum += sampleArr[i];
				avg=sum/BANDWIDTH_SAMPLE_RATE;
			}
			return avg;
		}
		
		
		public function convertSeekpoints(dat:Object) : Object{
			var kfr:Object = new Object();
			kfr['times'] = new Array();
			kfr['filepositions'] = new Array();
			for (var j:String in dat) {
				kfr['times'][j] = Number(dat[j]['time']);
				kfr['filepositions'][j] = Number(dat[j]['offset']);
			}
			return kfr;
		}
	}
}
