package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author daniel.sedlacek
	 */
	public class InteractivityEvent extends Event {
		
		public static const TRANSITION 				: String = "interactivityTransition";
		public static const SHOW_EMBED_SCREEN 		: String = "showEmbedScreen";
		public static const SHOW_PERMA_LINK 		: String = "showPermaLink";		
		private var _transition : Number;

		public function get transition() : Number {
			return _transition;
		}		
		public function InteractivityEvent(type : String, _transition : Number) {
			this._transition = _transition;
			
			super(type, false, false);
		}
	}
}
