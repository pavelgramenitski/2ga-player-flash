package com.rightster.player.media {
	/**
	 * @author Arun
	 */
	public dynamic class NetClient {
		public static const FCSUBSCRIBE : String = "fcsubscribe";
		public static const METADATA : String = "metadata";
		public static const CUEPOINT : String = "cuepoint";
		public static const TEXTDATA : String = "textdata";
		public static const COMPLETE : String = "complete";
		public static const XMPDATA : String = "xmpdata";
		public static const IMAGEDATA : String = "imagedata";
		public static const FI : String = "fi";
		public static const ID3 : String = "id3";
		
		private var callback : Object;
		
		public function NetClient(cbk : Object) : void {
			this.callback = cbk;
		}
		
		private function forward(data : Object, type : String) : void {
			data['type'] = type;
			callback.onClientData(data);
		}
		
		public function close(... rest) : void {
			forward({close: true}, COMPLETE);
		}
		
		public function onFCSubscribe(obj:Object) : void {
			forward(obj, FCSUBSCRIBE);
		}
		
		public function onMetaData(obj:Object, ...rest) : void {
			if (rest && rest.length > 0) {
				rest.splice(0, 0, obj);
				forward({ arguments: rest }, METADATA);
			} else {
				forward(obj, METADATA);
			}
		}
		
		public function onCuePoint(obj : Object) : void {
			forward(obj, CUEPOINT);			
		}
		
		public function onPlayStatus(... rest) : void {
			for each (var dat:Object in rest) {
				if (dat && dat.hasOwnProperty('code')) {
					if (dat.code == NetStreamCodes.PLAY_COMPLETE) {
						forward(dat, COMPLETE);
					}
				} 
			}
		}
		
		public function onTextData(obj : Object) : void {
			forward(obj, TEXTDATA);
		}
		
		public function onXMPData(obj : Object) : void {
			forward(obj, XMPDATA);
		}
		
		public function onImageData(obj : Object) : void {
			forward(obj, IMAGEDATA);
		}
		
		public function onFI(obj : Object) : void {
			forward(obj, FI);
		}
		
		public function onId3(obj : Object) : void {
			forward(obj, ID3);
		}
	}
}
