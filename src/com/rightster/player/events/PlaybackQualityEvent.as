package com.rightster.player.events {
	import flash.events.Event;

	/** 
	 * @author KJR
	 */
	public class PlaybackQualityEvent extends Event {
		// YouTube API
		public static const CHANGE : String = "PlaybackQualityEvent.CHANGE";
		public var value : String;

		public function PlaybackQualityEvent(type : String, value : String = null) {
			super(type, false, false);
			this.value = value;
		}

		override public function clone() : Event {
			return new PlaybackQualityEvent(type, value);
		}

		override public function toString() : String {
			return formatToString("PlaybackQualityEvent", "type", "bubbles", "cancelable", "eventPhase", "value");
		}
	}
}
