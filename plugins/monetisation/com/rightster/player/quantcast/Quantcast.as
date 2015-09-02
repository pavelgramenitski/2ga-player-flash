package com.rightster.player.quantcast {	
	import flash.display.Bitmap;
	import com.rightster.utils.Log;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.player.model.ErrorCode;
	import flash.display.MovieClip;
	import flash.net.URLRequest;
	
	import com.rightster.utils.AssetLoader;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;

	/**
	 * @author Rightster
	 */
	public class Quantcast extends MovieClip implements IPlugin {
		
		private static const QC_API_URL : String = "http://pixel.quantserve.com/pixel/{P_CODE}.gif?labels=Content.{CONTENT_ID}%2C%20Publisher.{PUBLISHER_ID}%2C%20Project.{PROJECT_ID}";
  		private static const QC_PCODE : String = "{P_CODE}";
  		private static const QC_CONTENT_ID : String = "{CONTENT_ID}";
		private static const QC_PUBLISHER_ID : String = "{PUBLISHER_ID}";
  		private static const QC_PROJECT_ID : String = "{PROJECT_ID}";
		
		private static const Z_INDEX   : int = PluginZindex.NONE;
		private static const VERSION   : String = "2.28.1";
		
		private var controller : IController;
		private var _initialized : Boolean;
		private var _loaded : Boolean = true;
		private var request : URLRequest;
		
		public function Quantcast() {
		}

		public function initialize(controller : IController, data : Object) : void {
			
			
			Log.write("Quantcast.initialize  * v  "+VERSION);
			
			if(!initialized){
				this.controller = controller;
				this._initialized = true;
				controller.addEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
			}
			
		}
		public function run(data : Object) : void{
			//nothing to do
		}

		public function close() : void{
			//nothing to do
		}
		

		public function dispose() : void {
			Log.write("Quantcast.dispose");
			if(_initialized) {
				controller.removeEventListener(PlayerStateEvent.CHANGE, onPlayerStateChange);
				controller = null;
				_initialized = false;
			}
		}
		
		private function onPlayerStateChange(event:PlayerStateEvent):void {
			if (controller.playerState == PlayerState.VIDEO_STARTED) {
				sendQuantCastBeacon();
			}
		}
		
		private function sendQuantCastBeacon():void{
			var url:String = QC_API_URL.replace(QC_PCODE,controller.placement.pcodeValue);// + controller.video.videoId;
			url = url.replace(QC_CONTENT_ID,controller.video.videoId.substr(0, 8));
			url = url.replace(QC_PUBLISHER_ID,controller.placement.publisherId);
			url = url.replace(QC_PROJECT_ID,controller.video.projectId);
			
			request = new URLRequest(url);
			
			controller.loader.load(request, AssetLoader.TYPE_IMG, null, false, ErrorCode.ASSET_LOADING_ERROR, "Quantcast.sendQuantCastBeacon * ", success);
		}
		
		public function get zIndex() : int {
			return Z_INDEX;
		}
		
		public function get loaded() : Boolean {
			return _loaded;
		}
		
		public function get initialized() : Boolean {
			return _initialized;
		}
		
		private function success(img : Bitmap) : void {
			Log.write("Quantcast.success");
		}
	}
}
