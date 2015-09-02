package com.rightster.player.skin {
	import flash.events.Event;

	/**
	 * @author KJR
	 */
	public class LoopButtonEvent extends Event {
		
		public static const LOOP_INACTIVE : String = "LoopButtonEvent.LOOP_INACTIVE";
		public static const LOOP_LIST : String = "LoopButtonEvent.LOOP_LIST";
		public static const LOOP_VIDEO : String = "LoopButtonEvent.LOOP_VIDEO";
				
		public function LoopButtonEvent(type : String) {
			super(type, false, false);
		}
	}
}
