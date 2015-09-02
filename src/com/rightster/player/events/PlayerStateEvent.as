package com.rightster.player.events {
	import flash.events.Event;

	/** 
	 * @author Daniel
	 */
	public class PlayerStateEvent extends Event {
		//YouTube API 
		public static const CHANGE : String = "onStateChange";
		
		private var _state : int;
		private var _previousState : int;
		
		public function get state() : int {
			return _state;
		}

		public function get previousState() : int {
			return _previousState;
		}

		public function PlayerStateEvent(type : String, state : int, previousState : int) {
			this._state = state;
			this._previousState = previousState;
			super(type, false, false);
		}
	}
}
