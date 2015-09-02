package com.rightster.player {
	import com.rightster.utils.AssetLoader;
	import com.rightster.player.events.TimedPlaylistEvent;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.view.Colors;
	import com.rightster.utils.TimeUtils;
	import com.rightster.utils.Log;	
	
	import flash.text.TextFormat;
	import flash.text.TextField;
	import flash.utils.setTimeout;	
	import flash.display.Bitmap;	
	import flash.net.URLRequest;
	import flash.display.Sprite;

	import com.rightster.player.model.IPlugin;
	import com.rightster.player.controller.IController;

	/**
	 * @author Arun
	 */
	public class CueCard extends Sprite implements IPlugin {
		private static const Z_INDEX : int = PluginZindex.ABOVE_CHROME;
		private static const VERSION : String = "2.20.2";
		private static const BG_COLOR : uint = 0x414042;
		
		private var controller : IController;
		private var _loaded : Boolean = true;
		private var bg : Sprite;
		private var cueCardImage : Bitmap;
		private var tf : TextField;
		private var format : TextFormat;
		private var lastItem : Boolean;
		
		public function CueCard() : void {
			Log.write("CueCard version " + VERSION);	
		}
		
		public function initialize(controller : IController, data : Object) : void {
			this.controller = controller;
			bg = new Sprite();
			
			tf = new TextField();
			tf.selectable = false;
			format = new TextFormat();
			tf.text = "";
			tf.defaultTextFormat = format;
			
			controller.addEventListener(TimedPlaylistEvent.STREAM_FINISHED, showHideCard);
			controller.addEventListener(TimedPlaylistEvent.STREAM_START, showHideCard);
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			
			this.visible = false;
		}

		public function dispose() : void {
			controller.removeEventListener(TimedPlaylistEvent.STREAM_FINISHED, showHideCard);
			controller.removeEventListener(TimedPlaylistEvent.STREAM_START, showHideCard);			
			controller.removeEventListener(ResizeEvent.RESIZE, resize);
			
			controller = null;
			bg = null;
			cueCardImage = null;
		}

		public function get zIndex() : int {
			return Z_INDEX;
		}

		public function get loaded() : Boolean {
			return _loaded;
		}
		
		private function showHideCard(evt : TimedPlaylistEvent) : void {			
			if (evt.type == TimedPlaylistEvent.STREAM_FINISHED) { 
				this.visible = true;
				lastItem = Boolean(evt.data['lastItem']);
				
				var request : URLRequest = new URLRequest(controller.video.startImageUrl);
				controller.loader.load(request, AssetLoader.TYPE_IMG, null, false, ErrorCode.ASSET_LOADING_ERROR, "ScreenshotLoader.load * ", complete);
			}
			else if (evt.type == TimedPlaylistEvent.STREAM_START) {
				this.visible = false;
			}
		}
		
		private function complete(data : *) : void {
			Log.write("CueCard.complete");
				
			cueCardImage = data as Bitmap;
			
			bg.graphics.beginFill(BG_COLOR);
			bg.graphics.drawRect(0, 0, controller.width, controller.height);
			bg.graphics.endFill();
			addChild(bg);			
			addChild(cueCardImage);			
			addChild(tf);
			
			tf.text = controller.video.title;
			
			format.font = "Arial";
			format.size = 12;
			format.color = Colors.primaryColor;
			tf.setTextFormat(format, 0, tf.text.length);
			
			resize(null);
			
			if (!lastItem) {
				setTimeout(startCountDown, 2000);
			}
		}
		
		private function resize(e : ResizeEvent) : void {
			Log.write("CueCard.resize * width : " + controller.width + ", height : " + controller.height);
			
			bg.x = 0;
			bg.y = 0;
			bg.width = controller.width;
			bg.height = controller.height;
			
			if (tf != null) {
				//tf.x = controller.width * 0.3;
				//tf.y = controller.height * 0.5;
				tf.width = controller.width * 0.7;
			}
			
			if (cueCardImage != null) {
			
				if (controller.width / controller.height > controller.stream.aspectRatio) {            
					cueCardImage.height = Math.round(controller.height);
					cueCardImage.width = Math.round(cueCardImage.height * controller.stream.aspectRatio);
					cueCardImage.x = Math.round(controller.width / 2 - cueCardImage.width / 2);
					cueCardImage.y = 0;
				} else {
					cueCardImage.width = Math.round(controller.width);
					cueCardImage.height = Math.round(cueCardImage.width / controller.stream.aspectRatio);
					cueCardImage.y = Math.round(controller.height / 2 - cueCardImage.height / 2);
					cueCardImage.x = 0;				
				}
			}
		}
		
		private function startCountDown() : void {
			Log.write("CueCard.startCountDown");
			
			controller.addEventListener(TimedPlaylistEvent.SHOW_COUNT_DOWN, updateCountDown);
		}
		
		private function updateCountDown(evt : TimedPlaylistEvent) : void {
			Log.write("CueCard.updateCountDown");
			
			var timeLeft : Number = Number(evt.data['time']);
			var showHours : Boolean = timeLeft > 3600 ? true : false;
			tf.text = "The show will start in: " + TimeUtils.formatSeconds(timeLeft, showHours);
			
			format.font = "Arial";
			format.size = 12;
			format.color = Colors.primaryColor;
			tf.setTextFormat(format, 0, tf.text.length);
		}
	}
}
