package com.rightster.utils {
	/**
	 * @author KJR
	 */
	public class Url {
		private var _url : String;

		public function Url(url : String = "") {
			_url = url.toLowerCase();
		}

		public function get value() : String {
			return _url;
		}

		public function get protocol() : Protocol {
			var str : String = _url.split("://")[0];
			var protocol : Protocol;

			switch( str ) {
				case "":
					protocol = Protocol.PROTOCOL_TYPE_NONE;
					break;
				case "file":
					protocol = Protocol.PROTOCOL_TYPE_FILE;
					break;
				case "http":
					protocol = Protocol.PROTOCOL_TYPE_HTTP;
					break;
				case "https":
					protocol = Protocol.PROTOCOL_TYPE_HTTPS;
					break;
			}

			return protocol;
		}
	}
}
