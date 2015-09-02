package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author Rightster
	 */
	public class GenericTrackerEvent extends Event {
		
		public static const TRACK : String = "track";
		
		public var customAction : String = "";
		
		public function GenericTrackerEvent(type : String, customAction : String) {
			super(type,  false, false);
			this.customAction = customAction;
		}
	}
}
