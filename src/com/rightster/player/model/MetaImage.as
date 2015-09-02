package com.rightster.player.model {
	/**
	 * @author Daniel
	 */
	public class MetaImage {
		private  var _uri : String;
		private var _quality : String;
		private var _width : Number;
		private var _height : Number;

		public function MetaImage(uri : String, quality : String, width : Number, height : Number) {
			this._height = height;
			this._width = width;
			this._quality = quality;
			this._uri = uri;
		}

		public function get uri() : String {
			return _uri;
		}

		public function get quality() : String {
			return _quality;
		}

		public function get width() : Number {
			return _width;
		}

		public function get height() : Number {
			return _height;
		}
	}
}
