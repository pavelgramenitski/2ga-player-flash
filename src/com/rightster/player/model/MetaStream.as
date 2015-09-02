package com.rightster.player.model {
	import com.rightster.utils.Log;
	import com.rightster.player.model.MetaQuality;
	/**
	 * @author Daniel
	 */
	public class MetaStream {
		public var aspectRatio : Number = 0; 
		public var quality : String;
		public var metaQuality : MetaQuality;
		public var uri : String;
		public var cdn : String;
		public var bitrate : uint = 0;
		
		public function MetaStream(quality : String) {
			this.quality = quality;
			
			Log.write("MetaStream " + quality);
		}
		
		
		public function toString() : String {
			return "MetaStream - aspectRatio: " + aspectRatio + " - quality: " + quality  + " - uri: " + uri + " - cdn: " + cdn + " - bitrate: " + bitrate + " - metaQuality: " + metaQuality.toString();
		}
	}
}
