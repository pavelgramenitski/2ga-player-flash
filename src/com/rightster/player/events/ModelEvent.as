package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author KJR
	 */
	public class ModelEvent extends Event {
		public static const PLAYBACK_AUTHORIZED : String = "ModelEvent.PLAYBACK_AUTHORIZED";
		public static const PLAYLIST_COMPLETE : String = "ModelEvent.PLAYLIST_COMPLETE";
		public static const VIDEO_DATA_COMPLETE : String = "ModelEvent.VIDEO_DATA_COMPLETE";
		public static const SCREENSHOT_COMPLETE : String = "ModelEvent.SCREENSHOT_COMPLETE";
		public static const SCREENSHOT_SHOW : String = "ModelEvent.SCREENSHOT_SHOW";
		public static const PLUGINS_COMPLETE : String = "ModelEvent.PLUGINS_COMPLETE";
		public static const MEDIA_COMPLETE : String = "ModelEvent.MEDIA_COMPLETE";
		public static const COOKIE_COMPLETE : String = "ModelEvent.COOKIE_COMPLETE";

		public function ModelEvent(type : String) {
			super(type, false, false);
		}
	}
}
