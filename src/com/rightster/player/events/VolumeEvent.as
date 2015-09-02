package com.rightster.player.events {
	import flash.events.Event;

	/** 
	 * @author Daniel
	 */
	public class VolumeEvent extends Event {
		public static const CHANGE : String = "volumeChange";
		public static const MUTE : String = "volumeMute";
		public static const UNMUTE : String = "volumeUnmute";
		
		public function VolumeEvent(type : String) {
			super(type, false, false);
		}
	}
}
