package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author KJR
	 */
	public class ErrorEvent extends Event {
		public static const ERROR : String = "onError";
		public var data : Object;

		public function ErrorEvent(type : String, data : Object) {
			super(type, false, false);
			this.data = data;
		}
	}
}
