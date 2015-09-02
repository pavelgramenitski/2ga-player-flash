package com.rightster.player.model {
	import com.rightster.player.Version;
	import com.rightster.utils.Delegate;

	import flash.utils.setTimeout;

	import com.rightster.utils.VolumeUtils;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.events.VolumeEvent;
	import com.rightster.utils.Log;

	import flash.events.NetStatusEvent;
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;

	/**
	 * @author Daniel
	 */
	public class CookieManager {
		private static const SO_NAME : String = "rightster_player_2ga_" + Version.VERSION;
		private static const FLUSH_SUCCESS : String = "SharedObject.Flush.Success";
		private static const FLUSH_FAILED : String = "SharedObject.Flush.Failed";
		private static const VOLUME : String = "volume";
		private static const VOLUME_NEW : String = "volume_new";
		private static const MUTED : String = "muted";
		private static const QUALITY : String = "quality";
		private static const USER_ID : String = "userId";
		private static const USER_SESSION : String = "userSession";
		private const STORAGE_STATUS_UNKNOWN : String = "CookieManager.STORAGE_STATUS_UNKNOWN";
		private const STORAGE_STATUS_REQUESTED : String = "CookieManager.STORAGE_STATUS_REQUESTED";
		private const STORAGE_STATUS_PENDING : String = "CookieManager.STORAGE_STATUS_PENDING";
		private const STORAGE_STATUS_APPROVED : String = "CookieManager.STORAGE_STATUS_APPROVED";
		private const STORAGE_STATUS_DENIED : String = "CookieManager.STORAGE_STATUS_DENIED";
		private const DISPATCH_LATER_DELAY : int = 2000;
		private var storageStatus : String;
		private var storageIsDirty : Boolean;
		private var sharedObject : SharedObject;
		private var controller : IController;
		private var _userId : String;
		private var _userSession : uint;

		public function CookieManager(controller : IController) {
			this.controller = controller;
			initializeLocalStorage();

			controller.setPlaybackQuality(sharedObject.data[QUALITY]);
			controller.addEventListener(PlaybackQualityEvent.CHANGE, onQualityChange);

			// now request save
			saveSharedObject();
		}

		public function dispose() : void {
			controller.removeEventListener(PlaybackQualityEvent.CHANGE, onQualityChange);

			if (sharedObject.hasEventListener(NetStatusEvent.NET_STATUS)) {
				sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
			}

			sharedObject = null;
			controller = null;
		}

		/*
		 * GETTERS/SETTERS
		 */
		public function get volume() : Number {
			return Number(sharedObject.data[VOLUME_NEW]);
		}

		public function set volume(volume : Number) : void {
			sharedObject.data[VOLUME_NEW] = volume;

			saveSharedObject();

			// always unmute after volume change
			muted = false;
			controller.dispatchEvent(new VolumeEvent(VolumeEvent.UNMUTE));
			controller.dispatchEvent(new VolumeEvent(VolumeEvent.CHANGE));
		}

		public function get muted() : Boolean {
			return Boolean(sharedObject.data[MUTED]);
		}

		public function set muted(muted : Boolean) : void {
			sharedObject.data[MUTED] = muted;

			if (muted) {
				controller.dispatchEvent(new VolumeEvent(VolumeEvent.MUTE));
			} else {
				controller.dispatchEvent(new VolumeEvent(VolumeEvent.UNMUTE));
			}

			saveSharedObject();
		}

		public function get userId() : String {
			return _userId;
		}

		public function set userId(uid : String) : void {
			_userId = uid;
			sharedObject.data[USER_ID] = uid;
			updatePlacementParamWithValue(USER_ID, uid);
			saveSharedObject();
		}

		public function set userSession(sid : uint) : void {
			_userSession = sid;
			sharedObject.data[USER_SESSION] = sid;
			updatePlacementParamWithValue(USER_SESSION, String(sid));
			saveSharedObject();
		}

		public function get userSession() : uint {
			return _userSession;
		}

		public function get quality() : String {
			var value : String = (sharedObject && sharedObject.data[QUALITY]) ? String(sharedObject.data[QUALITY]) : this.controller.placement.defaultQuality;
			return value;
		}

		/*
		 * EVENT HANDLERS
		 */
		private function onQualityChange(e : PlaybackQualityEvent) : void {
			sharedObject.data[QUALITY] = controller.getPlaybackQuality();
			saveSharedObject();
		}

		private function onFlushStatus(event : NetStatusEvent) : void {
			Log.write("CookieManager.onFlushStatus * code: " + event.info.code, Log.DATA);
			switch (event.info.code) {
				case FLUSH_SUCCESS :
					Log.write("CookieManager.onFlushStatus : user granted permission. value saved", Log.DATA);
					storageStatus = STORAGE_STATUS_APPROVED;
					sharedObjectToConsole();
					break;
				case FLUSH_FAILED :
					controller.error(ErrorCode.SHARED_OBJECT_UNAVAILABLE, 'CookieManager.onFlushStatus: ' + FLUSH_FAILED);
					storageStatus = STORAGE_STATUS_DENIED;
					break;
			}

			sharedObject.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
		}

		/*
		 * PRIVATE METHDOS
		 */
		private function initializeLocalStorage() : void {
			storageStatus = STORAGE_STATUS_UNKNOWN;

			// read or create a shared object
			sharedObject = getSharedObject();

			// TODO: KJR check importance of legacy conversion?
			if (sharedObject.data.hasOwnProperty(VOLUME)) {
				// read the previous VOLUME value and convert it to new style(1-100%) format and insert it into VOLUME_NEW
				sharedObject.data[VOLUME_NEW] = VolumeUtils.formatToUserLevel(Number(sharedObject.data[VOLUME]));

				// delete previous VOLUME from shared object- an attempt to save out will follow
				delete sharedObject.data[VOLUME];
			}

			sharedObject.data[VOLUME_NEW] = sharedObject.data.hasOwnProperty(VOLUME_NEW) ? Number(sharedObject.data[VOLUME_NEW]) : controller.config.DEFAULT_VOLUME;
			sharedObject.data[MUTED] = sharedObject.data.hasOwnProperty(MUTED) ? Boolean(sharedObject.data[MUTED]) : false;

			if (sharedObject.data.hasOwnProperty(QUALITY)) {
				sharedObject.data[QUALITY] = String(sharedObject.data[QUALITY]) ;
			} else if (controller.placement && controller.placement.hasOwnProperty("defaultQuality")) {
				sharedObject.data[QUALITY] = controller.placement.defaultQuality;
			}

			if (sharedObject.data.hasOwnProperty(USER_ID)) {
				userId = sharedObject.data[USER_ID];
			}

			if (sharedObject.data.hasOwnProperty(USER_SESSION)) {
				userSession = sharedObject.data[USER_SESSION];
			}
		}

		private function getSharedObject() : SharedObject {
			var so : SharedObject;
			try {
				so = SharedObject.getLocal(SO_NAME);
			} catch (err : Error) {
				controller.error(ErrorCode.SHARED_OBJECT_UNAVAILABLE, 'CookieManager.getSharedObject: ' + err.message);
			}

			return so;
		}

		private function saveSharedObject() : void {
			Log.write("CookieManager.saveSharedObject * storageStatus:" + storageStatus, Log.DATA);
			var flushStatus : String = null;

			if (storageStatus == STORAGE_STATUS_DENIED) {
				return;
			}

			if (storageStatus == STORAGE_STATUS_PENDING || storageStatus == STORAGE_STATUS_REQUESTED) {
				storageIsDirty = true;
				return;
			}

			try {
				if ((storageStatus != STORAGE_STATUS_PENDING) && (storageStatus != STORAGE_STATUS_APPROVED)) {
					storageStatus = STORAGE_STATUS_REQUESTED;
				}

				Log.write(storageStatus + " : attempt to flush and interpret SharedObjectFlushStatus ", Log.DATA);

				flushStatus = sharedObject.flush();
			} catch(err : Error) {
				storageStatus = STORAGE_STATUS_DENIED;
				storageIsDirty = false;
				// give the controller placement an arbitrary amount of time to configure itself before dispatching this non-blocking error
				setTimeout(Delegate.create(controller.error, ErrorCode.SHARED_OBJECT_UNAVAILABLE, 'CookieManager.getSharedObject: ' + err.message), DISPATCH_LATER_DELAY);
			}

			if (flushStatus != null) {
				switch (flushStatus) {
					case SharedObjectFlushStatus.PENDING :
						Log.write("CookieManager.saveSharedObject : requesting permission to save shared object", Log.DATA);
						storageStatus = STORAGE_STATUS_PENDING;
						sharedObject.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus, false, 0, true);
						break;
					case SharedObjectFlushStatus.FLUSHED :
						Log.write("CookieManager.saveSharedObject : success - value flushed to disk", Log.DATA);
						// success - must be approved
						storageStatus = STORAGE_STATUS_APPROVED;
						// if dirty, flush again to ensure all updates are saved
						if (storageIsDirty) {
							storageIsDirty = false;
							saveSharedObject();
						}
						break;
				}
			}
		}

		private function updatePlacementParamWithValue(param : String, value : String) : void {
			if (controller.placement && controller.placement.hasOwnProperty(param)) {
				controller.placement[param] = value;
			} else {
				controller.setDirtyPlacementValue(param, value);
			}
		}

		private function sharedObjectToConsole() : void {
			Log.write("CookieManager.sharedObjectToConsole", Log.DATA);
			for (var key : String in sharedObject.data) {
				Log.write(key + ": " + sharedObject.data[key], Log.DATA);
			}
		}
	}
}