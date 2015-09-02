package com.rightster.player.model {
	import com.rightster.utils.Log;
	
	/**
	 * @author Daniel
	 */
	public class MetaPlugin {
		
		private var _name : String;
		private var _url : String;
		private var _data : Object;
		private var _layer : int;
		
		public function get name() : String {
			return _name;
		}
		
		public function get url() : String {
			return _url;
		}
		
		public function get data() : Object {
			return _data;
		}
		
		public function get layer() : int {
			return _layer;
		}
		
		public function MetaPlugin(_name : String, _url : String, _data : Object = null) {
			this._name = _name;
			this._url = _url;
			this._data = _data == null ? {} : _data;
			this._layer = _layer;
			
			Log.write(toString());
		}
		
		public function toString() : String {
			return "MetaPlugin - " + _name + " - " + _url;
		}
	}
}
