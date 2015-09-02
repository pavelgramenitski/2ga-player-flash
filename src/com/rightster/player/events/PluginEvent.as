package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author KJR
	 */
	public class PluginEvent extends Event {
		public static const REFRESH : String = "PluginEvent.REFRESH";

		public function PluginEvent(type : String) {
			super(type, false, false);
		}
	}
}
