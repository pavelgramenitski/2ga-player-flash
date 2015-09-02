package com.rightster.player.model {
	/**
	 * @author KJR
	 */
	public class MetaError {
		
		private  var _code : int;
		private var _message : String;
		
		public function MetaError(code:int,message:String):void
		{
			this._code = code;
			this._message = message;
		}
		
		public function get code() : int {
			return _code;
		}

		public function get message() : String {
			return _message;
		}
		
		public function toString() : String {
			return "MetaError - " + _code + " - " + _message;
		}
	}
}
