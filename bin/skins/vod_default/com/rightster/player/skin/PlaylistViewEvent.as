package com.rightster.player.skin {
	import flash.events.Event;

	/**
	 * @author Daniel
	 */
	public class PlaylistViewEvent extends Event {
		
		public static const SHOW : String = "playlistViewShow";
		public static const HIDE : String = "playlistViewHide";
				
		public function PlaylistViewEvent(type : String) {
			super(type, false, false);
		}
	}
}
