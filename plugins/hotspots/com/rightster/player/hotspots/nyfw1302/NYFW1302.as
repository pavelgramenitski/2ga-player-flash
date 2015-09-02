package com.rightster.player.hotspots.nyfw1302 {
	import com.gskinner.motion.GTweener;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.GenericTrackerEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;

	/**
	 * @author Daniel
	 */
	public class NYFW1302 extends MovieClip implements IPlugin {
		
		private static const VERSION : String = "2.9.9";
		private static const REF_W : Number = 800;
		private static const REF_H : Number = 450;
		private static const FADE_IN_TIME : Number = 0.4;
		
		private var controller : IController;
		private var spot : Sprite;
		private var spotId : uint;
		private var alignX : Number;
		private var alignY : Number;
		private var _loaded : Boolean = true;

		public function NYFW1302() {
			Log.write("NYFW1302 version " + VERSION);
			this.buttonMode = true;
			this.useHandCursor = true;
			this.addEventListener(MouseEvent.CLICK, click);
		}

		public function initialize(controller : IController, data : Object) : void {
			this.controller = controller;
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			this.addEventListener(Event.ENTER_FRAME, tick);
		}

		private function click(event : MouseEvent) : void {
			controller.pauseVideo();
			controller.fullScreen = false;
			controller.dispatchEvent(new GenericTrackerEvent(GenericTrackerEvent.TRACK, "nyfw1302_" + spotId + "_"));
			navigateToURL(new URLRequest("http://www.harpersbazaar.com/"), "_blank");
		}

		private function resize(event : ResizeEvent = null) : void {
			if (spot == null || controller.video == null) {
				return;
			}
			
			var _width : Number;
			var _height : Number;
			var _x : Number;
			var _y : Number;
			var _scale : Number;
			
			//don't resize if stream is not defined
			if (controller.stream == null) {
				return;
			}
			//keep aspect ratio
			if (controller.width / controller.height > controller.stream.aspectRatio) {            
				height = Math.round(controller.height);
				width = Math.round(height * controller.stream.aspectRatio);
				_scale = _height / REF_H;
			} else {
				width = Math.ceil(controller.width);
				height = Math.ceil(width / controller.stream.aspectRatio);
				_scale = _width / REF_W;
			}
			 
			//apply pixel limit
			if (controller.video.pixelLimit > 0 && controller.video.pixelLimit < _width * _height) {
				var oversize : Number = _width * _height / controller.video.pixelLimit;
				_width = _width / Math.sqrt(oversize);
				_height = _height / Math.sqrt(oversize); 	
			}
			
			//allign in the middle
			_x = Math.round(controller.width / 2 - _width / 2);
			_y = Math.round(controller.height / 2 - _height / 2);
			
			spot.scaleX = spot.scaleY = _scale;
			spot.x = alignX * _width + _x - alignX * spot.width;
			spot.y = alignY * _height + _y - alignY * spot.height;
		}

		private function tick(event : Event) : void {
			
			this.gotoAndStop(Math.ceil(controller.getCurrentTime()));
			
			for (var i : int = 0; i < 3; i++) {
				if (this["hotspot" + i] != null && this["hotspot" + i] != spot) {
					spot = this["hotspot" + i];
					spotId = i;
					//Log.write(spot + " - " + i, Log.ERROR);
					alignX = spot.x / (REF_W - spot.width);
					alignY = spot.y / (REF_H - spot.height);
					//Log.write(" new spot ", alignX, alignY, Log.ERROR);
					spot.mouseChildren = false;
					spot.alpha = 0;
					GTweener.to(spot, FADE_IN_TIME, {alpha:1});
					break;
				}
			}
			
			if (spot != null && this.currentFrameLabel == "hide") {
				GTweener.to(spot, FADE_IN_TIME, {alpha:0});
			}
			resize();
		}

		public function dispose() : void {
			this.removeEventListener(Event.ENTER_FRAME, tick);
			controller.removeEventListener(ResizeEvent.RESIZE, resize);
			controller = null;
		}

		public function get zIndex() : int {
			return PluginZindex.BELOW_CHROME;
		}
		public function get loaded() : Boolean {
			return _loaded;
		}
	}
}
