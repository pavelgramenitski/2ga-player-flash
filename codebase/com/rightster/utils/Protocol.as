package com.rightster.utils {
	/**
	 * @author KJR
	 */
	public class Protocol {
		public static const PROTOCOL_TYPE_NONE : Protocol = new Protocol(0, "");
		public static const PROTOCOL_TYPE_FILE : Protocol = new Protocol(1, "file");
		public static const PROTOCOL_TYPE_HTTP : Protocol = new Protocol(2, "http");
		public static const PROTOCOL_TYPE_HTTPS : Protocol = new Protocol(3, "https");
		private var _type : int;
		private var _value : String;

		public function Protocol(type : int = 0, value : String = "") {
			_type = type;
			_value = value;
		}

		public function toString() : String {
			return "Protocol type: " + _type + " name: " + _value;
		}

		public function get value() : String {
			return _value;
		}

		public function get type() : int {
			return _type;
		}
	}
}
