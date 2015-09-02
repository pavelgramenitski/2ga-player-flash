package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author Arun
	 */
	public class LoopModeEvent extends Event {
		public static const CHANGE : String = "LoopModeEvent.CHANGE";
		
		public function LoopModeEvent(type : String) {
			super(type, false, false);
		}
	}
}
