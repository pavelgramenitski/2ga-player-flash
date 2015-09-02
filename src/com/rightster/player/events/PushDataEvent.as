package com.rightster.player.events {
	import flash.events.Event;

	/**
	 * @author Arun
	 */
	public class PushDataEvent extends Event {
		public static const COMMAND_RECIEVED : String = "commandRecieved";
		
		public var command : String;
		public var data : Object;
		
		public function PushDataEvent(type : String, command : String, data : Object = null) : void {
			super(type, false, false);
			this.command = command;
			this.data = data;
		}
	}
}
