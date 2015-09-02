package com.rightster.player.view {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.utils.Log;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author Daniel Sedlacek
	 */
	public class ErrorScreen extends Sprite {
		
		private static const NATIVE_ERROR: String = "Network connection error.";
		private static const WAIT_SEONCDS : int = 3;
		
		private var controller : IController;
		private var bg : Sprite;
		private var errorMessageTxt : TextField;
		private var countdownTxt : TextField;
		private var errorCodeText : TextField;
		private var loader : Loader;
		private var request : URLRequest;
		private var textFormat : TextFormat;
		private var timer : Timer;
		private var showTimer : Boolean;
		
		public function ErrorScreen(controller : IController) {
			this.controller = controller;
			
			showTimer = false;
			
			bg = new Sprite();
			bg.graphics.beginFill(0x000000);
			bg.graphics.drawRect(0, 0, 1, 1);
			bg.graphics.endFill();
			addChild(bg);
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.contentLoaderInfo.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			loader.visible = false;
			addChild(loader);
			
			textFormat = new TextFormat();
			textFormat.font = "Arial";
			textFormat.size = 17;
			textFormat.align = TextFormatAlign.CENTER;
			
			errorMessageTxt = new TextField();
			errorMessageTxt.textColor = 0xffffff;
			errorMessageTxt.selectable = false;
			errorMessageTxt.autoSize = TextFieldAutoSize.LEFT;
			errorMessageTxt.setTextFormat(textFormat);
			errorMessageTxt.visible = false;
			addChild(errorMessageTxt);
			
			countdownTxt = new TextField();
			countdownTxt.textColor = 0xffffff;
			countdownTxt.selectable = false;
			countdownTxt.autoSize = TextFieldAutoSize.LEFT;
			countdownTxt.setTextFormat(textFormat);
			countdownTxt.visible = false;
			addChild(countdownTxt);
			
			errorCodeText = new TextField();
			errorCodeText.visible = false;
			addChild(errorCodeText);	
			visible = false;
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			resize();
		}	

		public function error(code : String, message : String, blocking : Boolean = false) : void {
			Log.write(code + " - " + message, Log.ERROR);
			updateErrorCode(code);
			errorCodeText.visible = true;
			if (blocking) {
				if (controller.placement.showPlaylist && code == ErrorCode.MEDIA_URLS_EMPTY) {
					request = new URLRequest(controller.placement.path + controller.config.ERROR_SCREEN_PLAYLIST);
					showTimer = true;
				}
				else if (code == ErrorCode.CONTENT_GEOBLOCKED){
					request = new URLRequest(controller.placement.path + controller.config.ERROR_SCREEN_GEO);
				}
				else {
					request = new URLRequest(controller.placement.path + controller.config.ERROR_SCREEN_DEFAULT);
				}
				load();
			}
		}
		
		private function load() : void {
			Log.write("ErrorScreen.load * URL:"+request.url, Log.NET);
			try {
				loader.load(request);
			} catch (err : Error) {
				Log.write(ErrorCode.ASSET_LOADING_ERROR, "ErrorScreen.load * " + err.message + " * url: " + request.url, Log.ERROR);
				fallbackError();
			}
		}
		
		private function completeHandler(event : Event) : void {
			loader.visible = true;
			visible = true;
			if (showTimer) {
				errorMessageTxt.text = "This video is no longer available.";
				textFormat.size = 17;
				errorMessageTxt.setTextFormat(textFormat);
				errorMessageTxt.visible = true;
				
				countdownTxt.text = "Next video in " + WAIT_SEONCDS + " secs >>";
				textFormat.size = 12;
				countdownTxt.setTextFormat(textFormat);
				countdownTxt.visible = true;
				
				timer = new Timer(1000, WAIT_SEONCDS);
				timer.addEventListener(TimerEvent.TIMER, updateCount);
				timer.start();				
			}
			resize();
		}
		
		private function updateCount(e : TimerEvent) : void {
			countdownTxt.text = "Next video in "+ (timer.repeatCount - timer.currentCount) +" secs >>";
			textFormat.size = 12;
			countdownTxt.setTextFormat(textFormat);
			countdownTxt.visible = true;
			
			if (timer.repeatCount - timer.currentCount == 0) {
				timer.stop();
				timer.removeEventListener(TimerEvent.TIMER, updateCount);
				timer = null;
				visible = false;
				controller.nextVideo();
			}
		}
		private function resize(e : ResizeEvent = null) : void {
			bg.x = bg.y = 0;
			bg.width = controller.width;
			bg.height = controller.height;
			
			errorMessageTxt.x = controller.width / 2 - errorMessageTxt.width / 2;
			errorMessageTxt.y = controller.height / 2 - (errorMessageTxt.height + 20);
			
			countdownTxt.x = controller.width / 2 - countdownTxt.width / 2;
			countdownTxt.y = controller.height / 2 - (countdownTxt.height - 20);
			
			errorCodeText.x = controller.width  - errorCodeText.width;
			errorCodeText.y = controller.height  - errorCodeText.height ;
			
			this.setChildIndex(errorCodeText, this.numChildren-1);
			if (loader.visible) {
				var ar : Number = loader.width / loader.height;
				if (controller.width / controller.height > ar) {            
					loader.height = Math.round(controller.height);
					loader.width = Math.round(loader.height * ar);
					loader.x = Math.round(controller.width / 2 - loader.width / 2);
					loader.y = 0;
				} else {
					loader.width = Math.round(controller.width);
					loader.height = Math.round(loader.width / ar);				
					loader.y = Math.round(controller.height / 2 - loader.height / 2);
					loader.x = 0;	
				}
			}
		}
		
		private function fallbackError() : void {
			errorMessageTxt.text = NATIVE_ERROR;
			errorMessageTxt.visible = true;
			visible = true;
		}
		private function updateErrorCode(value : String):void{
			var format : TextFormat = new TextFormat();
			format.font = "_sans";
			format.size = 9;
			format.align = TextFormatAlign.CENTER;
			
			errorCodeText.textColor = 0x999999;
			errorCodeText.selectable = false;
			errorCodeText.text = "Code:"+value;
			errorCodeText.autoSize = TextFieldAutoSize.LEFT;
			errorCodeText.setTextFormat(format);
		}

		
		private function errorHandler(err : Event) : void {
			controller.error(ErrorCode.ASSET_LOADING_ERROR, "ErrorScreen.errorHandler * " + err['text'] + " * url: " + request.url);
			fallbackError();
		}
	}
}