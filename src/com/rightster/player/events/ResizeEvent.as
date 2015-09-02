package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author Daniel
	 */
	public class ResizeEvent extends Event {
		
		public static const RESIZE : String = "resizeResize";
		public static const ENTER_FULLSCREEN : String = "resizeEnterFullscreen";
		public static const EXIT_FULLSCREEN : String = "resizeExitFullscreen";
		
		public function ResizeEvent(type : String) {
			super(type, false, false);
		}
	}
}