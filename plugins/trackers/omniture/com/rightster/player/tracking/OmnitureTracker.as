package com.rightster.player.tracking {
	import com.rightster.player.events.MediaProviderEvent;	
	import com.rightster.player.events.PlayerStateEvent;	
	import com.rightster.player.controller.IController;
	import com.rightster.player.model.PluginZindex;	
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlugin;
	import com.rightster.utils.Log;	

	import com.omniture.AppMeasurement;
	import flash.display.MovieClip;
	import flash.events.Event;
	
	/**
	 * @author Rightster
	 */
	public class OmnitureTracker extends MovieClip implements IPlugin {
		
		private static const Z_INDEX:int = PluginZindex.NONE;
		private static const VERSION : String = "2.22.2";
		private static const CONFIG_XML_URL : String = "omnitureXMLPath";
		private static const MEDIA_PLAYER_NAME : String = "Rightster Player";
		
		private var controller : IController;
		private var data : Object;
		private var initialized	: Boolean;
		
		private var _oTracker : AppMeasurement;
		private var _loaded : Boolean = false;
		
		public function OmnitureTracker() {
			Log.write("OmnitureTracker version " + VERSION);
			
			_oTracker = new AppMeasurement();
		}

		public function initialize(controller : IController, data : Object) : void {
			Log.write("OmnitureTracker.initialize");
			
			this.controller = controller;
			this.data = data;
			
			configAppMeasurement();
			
			controller.addEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
			controller.addEventListener(MediaProviderEvent.META_DATA, onMetaData);
			
			initialized = true;
			_loaded = true;
		}
		
		public function dispose() : void {
			if (initialized) {
				controller.removeEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
				controller.removeEventListener(MediaProviderEvent.META_DATA, onMetaData);
				
				_loaded = false;
				data = null;
				controller = null;
			}
		}

		public function get zIndex() : int {
			return Z_INDEX;
		}
		
		public function get loaded() : Boolean {
			return _loaded;
		}
		
		private function onMetaData(event : MediaProviderEvent) : void {
			mediaOpen(controller.video.videoId, controller.getDuration(), MEDIA_PLAYER_NAME);
			mediaPlay(controller.video.videoId, controller.getCurrentTime());
		}
		
		private function configAppMeasurement() : void {
			if (!initialized) {
				try {				
					var xmlUrl : String = controller.placement.path + data[CONFIG_XML_URL];
					Log.write(xmlUrl, Log.NET);
					_oTracker.configURL = xmlUrl;
					addChild(_oTracker);
				}
				catch (err:Error) {
					controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "OmnitureTracker.configAppMeasurement * " + err.message);
				}
			}
		}
		
		private function onPlayerStateChange(event : Event) : void {			
			switch (controller.playerState)	{				
				case PlayerState.VIDEO_PLAYING :
					if (controller.getDuration() > 0) {
						mediaPlay(controller.video.videoId, controller.getCurrentTime());
					}
				break;
				
				case PlayerState.VIDEO_PAUSED :
				case PlayerState.PLAYER_BUFFERING :
					mediaStop(controller.video.videoId, controller.getCurrentTime());
				break;
				
				case PlayerState.VIDEO_ENDED :
					mediaStop(controller.video.videoId, controller.getCurrentTime());
					mediaClose(controller.video.videoId);
					break;
			}
		}
		
		private function mediaOpen(mediaName : String, mediaLength : Number, mediaPlayerName : String) : void {
			Log.write("OmnitureTracker.mediaOpen * mediaName : " + mediaName + ", mediaLength : " + mediaLength + ", mediaPlayerName : " + mediaPlayerName);
			_oTracker.Media.open(mediaName, mediaLength, mediaPlayerName);
		}
		
		private function mediaPlay(mediaName : String, mediaOffset : Number) : void {
			Log.write("OmnitureTracker.mediaPlay * mediaName : " + mediaName + ", mediaOffset : " + mediaOffset);
			_oTracker.Media.play(mediaName, mediaOffset);
		}
		
		private function mediaStop(mediaName : String, mediaOffset : Number) : void {
			Log.write("OmnitureTracker.mediaStop * mediaName : " + mediaName + ", mediaOffset : " + mediaOffset);
			_oTracker.Media.stop(mediaName, mediaOffset);
		}
		
		private function mediaClose(mediaName : String) : void {
			Log.write("OmnitureTracker.mediaClose * mediaName : " + mediaName);
			_oTracker.Media.close(mediaName);
		}
	}
}
