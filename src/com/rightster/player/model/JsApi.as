package com.rightster.player.model {
	import com.rightster.player.events.ErrorEvent;
	import com.rightster.player.events.PlaybackQualityEvent;

	import flash.utils.Dictionary;
	// import com.rightster.utils.Guid;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.utils.Log;

	import flash.external.ExternalInterface;

	/**
	 * @author KJR
	 */
	public class JsApi {
		private var controller : IController;
		private var subscriptions : Dictionary;
		private var initialized : Boolean = false;

		public function JsApi(controller : IController) {
			this.controller = controller;
			subscriptions = new Dictionary();
		}

		public function initialize() : void {
			Log.write('JsApi.initialize * apiEnabled: ' + controller.placement.jsApi + ', ExternalInterface.available: ' + ExternalInterface.available, Log.SYSTEM);

			if (controller.placement.jsApi) {
				shouldInitialize();
			}
		}

		public function shouldInitialize() : Boolean {
			if (available && !initialized) {
				initialized = true;
				configure();
				dispatchIsReady();
				return true;
			} else if (!available) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.initialize * ExternalInterface not available");
			}
			
			return false;
		}

		public function get available() : Boolean {
			return ExternalInterface.available;
		}

		public function get objectId() : String {
			Log.write("objectId is: " + ExternalInterface.objectID);
			return ExternalInterface.objectID;
		}

		public function openNewWindow(url : String, properties : String) : void {
			if (available) {
				Log.write("JsApi::openNewWindow : " + url);
				try {
					ExternalInterface.call("window.open", url, "_blank", properties);
				} catch(error : Error) {
					//
					controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.openNewWindow * " + error.message);
				}
			}
		}

		private function dispatchIsReady() : void {
			Log.write("JsApi::dispatchIsReady");

			// public api
			try {
				ExternalInterface.call("onRightsterPlayerApiReady", objectId);
			} catch(error : Error) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi::dispatchIsReady::public * " + error.message);
			}

			// internal api
			try {
				ExternalInterface.call("RPFlashMediator.PlayerApiReady", objectId);
			} catch(error : Error) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi::dispatchIsReady::internal * " + error.message);
			}
		}

		private function configure() : void {
			controller.addEventListener(PlayerStateEvent.CHANGE, playerState);
			controller.addEventListener(PlaybackQualityEvent.CHANGE, handlePlaybackQualityEvent);
			controller.addEventListener(ErrorEvent.ERROR, handleErrorEvent);

			try {
				// *** Queueing functions ***
				ExternalInterface.addCallback("cueVideoById", controller.cueVideoById);
				ExternalInterface.addCallback("loadVideoById", controller.loadVideoById);
				// ExternalInterface.addCallback("cueVideoByUrl", controller.cueVideoByUrl);
				// ExternalInterface.addCallback("loadVideoByUrl", controller.loadVideoByUrl);
				ExternalInterface.addCallback("cuePlaylist", controller.cuePlaylist);
				ExternalInterface.addCallback("loadPlaylist", controller.loadPlaylist);
				// *** Playback controls and player settings ***
				ExternalInterface.addCallback("playVideo", controller.playVideo);
				ExternalInterface.addCallback("pauseVideo", controller.pauseVideo);
				ExternalInterface.addCallback("seekTo", controller.seekTo);
				// *** Playing a video in a playlist
				ExternalInterface.addCallback("nextVideo", controller.nextVideo);
				ExternalInterface.addCallback("previousVideo", controller.previousVideo);
				ExternalInterface.addCallback("playVideoAt", controller.playVideoAt);
				// *** Changing the player volume
				ExternalInterface.addCallback("mute", controller.mute);
				ExternalInterface.addCallback("unMute", controller.unMute);
				ExternalInterface.addCallback("isMuted", controller.isMuted);
				ExternalInterface.addCallback("setVolume", controller.setVolume);
				ExternalInterface.addCallback("getVolume", controller.getVolume);
				// *** Setting the player size
				// defr to the html wrapper api
				ExternalInterface.addCallback("setSize", controller.setSize);
				// *** Setting playback behavior for playlists

				// map to setLoopMode
				ExternalInterface.addCallback("setLoop", controller.setLoopMode);
				// 0,1,2

				ExternalInterface.addCallback("setShuffle", controller.setShuffle);

				// *** Playback status ***
				ExternalInterface.addCallback("getVideoBytesLoaded", controller.getVideoBytesLoaded);
				ExternalInterface.addCallback("getVideoBytesTotal", controller.getVideoBytesTotal);
				ExternalInterface.addCallback("getVideoStartBytes", controller.getVideoStartBytes);
				ExternalInterface.addCallback("getPlayerState", controller.getPlayerState);
				ExternalInterface.addCallback("getCurrentTime", controller.getCurrentTime);
				// *** Playback quality ***
				ExternalInterface.addCallback("getPlaybackQuality", controller.getPlaybackQuality);
				ExternalInterface.addCallback("setPlaybackQuality", controller.setPlaybackQuality);
				ExternalInterface.addCallback("getAvailableQualityLevels", controller.getAvailableQualityLevels);
				// *** video information and playlist information ***
				ExternalInterface.addCallback("getDuration", controller.getDuration);

				// TODO: required?
				// ExternalInterface.addCallback("getVideoUrl", controller.getVideoUrl);
				// ExternalInterface.addCallback("getVideoEmbedCode", controller.getVideoEmbedCode);

				ExternalInterface.addCallback("getPlaylist", controller.getPlaylist);
				ExternalInterface.addCallback("getPlaylistIndex", controller.getPlaylistIndex);

				// *** Event subscription ***
				ExternalInterface.addCallback("subscribe", this.subscribe);
			} catch (err : Error) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.initialize * " + err.message);
			}
		}

		private function subscribe(eventName : String, fncName : String) : void {
			Log.write("JsApi.subscribe *eventName: " + eventName + " *fncName: " + fncName);

			try {
				registerSubscription(eventName, fncName);
			} catch(error : Error) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.subscribe * " + error.message);
			}
		}

		private function registerSubscription(eventName : String, fncName : String) : void {
			if (!subscriptions[eventName]) {
				subscriptions[eventName] = fncName;
			} else if (subscriptions[eventName] is Array) {
				subscriptions[eventName].push(fncName);
			} else if (subscriptions[eventName] is String) {
				var tmpName : String = subscriptions[eventName];
				var arr : Array = [tmpName, fncName];
				subscriptions[eventName] = arr;
			}
		}

		private function getNotifiersForSubscriber(eventName : String) : Array {
			if (subscriptions[eventName] != null) {
				if (subscriptions[eventName] is Array) {
					return subscriptions[eventName];
				} else if (subscriptions[eventName] is String) {
					return [subscriptions[eventName]];
				}
			}
			return null;
		}

		private function playerState(event : PlayerStateEvent) : void {
			try {
				var arr : Array = getNotifiersForSubscriber(event.type);
				if (!arr) {
					return;
				}
				var obj : Object = {};
				// TODO:change to 'data' from  'state'
				obj.data = controller.playerState;
				obj.playerId = objectId;

				for (var len : int = arr.length, i : int = 0; i < len; ++i) {
					var fncName : String = arr[i];
					if (fncName) {
						try {
							ExternalInterface.call(fncName, obj);
						} catch(e : Error) {
							controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.handlePlaybackQualityEvent * " + e.message);
						}
					}
				}
			} catch(err : Error) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.playerState * " + err.message);
			}
		}

		private function handlePlaybackQualityEvent(event : PlaybackQualityEvent) : void {
			try {
				var arr : Array = getNotifiersForSubscriber(event.type);
				if (!arr) {
					return;
				}
				var obj : Object = {};
				obj.data = controller.getPlaybackQuality();
				obj.playerId = objectId;

				for (var len : int = arr.length, i : int = 0; i < len; ++i) {
					var fncName : String = arr[i];
					if (fncName) {
						try {
							ExternalInterface.call(fncName, obj);
						} catch(e : Error) {
							controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.handlePlaybackQualityEvent * " + e.message);
						}
					}
				}
			} catch(err : Error) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.handlePlaybackQualityEvent * " + err.message);
			}
		}

		private function handleErrorEvent(event : ErrorEvent) : void {
			Log.write("JsApi::handleErrorEvent *event: " + event);
			try {
				var arr : Array = getNotifiersForSubscriber(event.type);
				if (!arr) {
					return;
				}
				var obj : Object = {};
				obj.data = event.data;
				obj.playerId = objectId;

				for (var len : int = arr.length, i : int = 0; i < len; ++i) {
					var fncName : String = arr[i];
					if (fncName) {
						try {
							ExternalInterface.call(fncName, obj);
						} catch(e : Error) {
							controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.handleErrorEvent * " + e.message);
						}
					}
				}
			} catch(err : Error) {
				controller.error(ErrorCode.JS_API_UNAVAILABLE, "JsApi.handleErrorEvent * " + err.message);
			}
		}
	}
}
