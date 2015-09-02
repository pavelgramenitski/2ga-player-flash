package com.rightster.player.model {
	/**
	 * @author KJR
	 */
	public class MetaQuality {
		
		private  var _quality : String;
		private var _label : String;
		
		public function MetaQuality(quality:String,label:String):void
		{
			this._quality = quality;
			this._label = label;
		}
		
		public function get quality() : String {
			return _quality;
		}

		public function get label() : String {
			return _label;
		}
		
		public function toString() : String {
			return "MetaQuality - " + this._quality + " - " + this._label;
		}
	}
}
