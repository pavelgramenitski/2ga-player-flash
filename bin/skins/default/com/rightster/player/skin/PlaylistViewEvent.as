package com.rightster.player.skin {
	import flash.events.Event;

	/**
	 * @author KJR
	 */
	public class PlaylistViewEvent extends Event {
		
		public static const SHOW : String = "PlaylistViewEvent.SHOW";
		public static const HIDE : String = "PlaylistViewEvent.HIDE";
		public static const NEXT : String = "PlaylistViewEvent.NEXT";
		public static const PREVIOUS : String = "PlaylistViewEvent.PREVIOUS";
				
		public function PlaylistViewEvent(type : String) {
			super(type, false, false);
		}
	}
}
