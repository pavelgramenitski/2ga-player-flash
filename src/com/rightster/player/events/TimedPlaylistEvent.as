package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author Arun
	 */
	public class TimedPlaylistEvent extends Event {
		public static const SHOW_COUNT_DOWN : String = "showCountDown";
		public static const STREAM_START : String = "streamStart";
		public static const STREAM_FINISHED : String = "streamFinished";
		
		public var data : Object;
		
		public function TimedPlaylistEvent(type : String, data : Object = null) {
			super(type, false, false);
			this.data = data;
		}
	}
}
