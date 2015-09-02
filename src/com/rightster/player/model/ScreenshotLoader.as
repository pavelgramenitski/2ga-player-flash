package com.rightster.player.model {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ModelEvent;
	import com.rightster.utils.Log;

	import flash.display.DisplayObject;
	import flash.display.Loader;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;

	/**
	 * @author KJR
	 */
	public class ScreenshotLoader {
		private var controller : IController;
		private var request : URLRequest;
		private var showOnCompleteIsDirty : Boolean = false;
		private var loader : Loader;
		private var loaded : Boolean;

		public function ScreenshotLoader(controller : IController) : void {
			this.controller = controller;
		}

		public function dispose() : void {
			unregisterEventListeners();
			try {
				if (loader) {
					loader.unloadAndStop(true);
					if (loader.parent) {
						loader.parent.removeChild(loader);
					}
				}
			} catch(error : Error) {
				Log.write('ScreenshotLoader.dispose ERROR', Log.ERROR);
			}
		}

		public function load(url : String) : void {
			Log.write('ScreenshotLoader.load * url: ' + url);
			if (!loaded) {
				request = new URLRequest(url);
				Log.write('ScreenshotLoader...making request');
				try {
					loader = new Loader();
					registerEventListeners();
					loader.load(request);
					Log.write('ScreenshotLoader...making load');
				} catch (err : Error) {
					Log.write('ERROR ScreenshotLoader.load * url: ' + url + 'error: ' + err, Log.ERROR);
					errorHandler();
				}
				loaded = true;
			}
		}

		public function loadAndShowOnComplete(url : String) : void {
			Log.write('ScreenshotLoader.loadAndShowOnComplete * url: ' + url);
			showOnCompleteIsDirty = true;
			load(url);
		}

		private function completeHandler(event : Event) : void {
			Log.write('ScreenshotLoader.completeHandler');
			controller.addScreenshot(loader as DisplayObject);
			controller.dispatchEvent(new ModelEvent(ModelEvent.SCREENSHOT_COMPLETE));
			if (showOnCompleteIsDirty) {
				showOnCompleteIsDirty = false;
				controller.dispatchEvent(new ModelEvent(ModelEvent.SCREENSHOT_SHOW));
			}
		}

		private function errorHandler() : void {
			Log.write('ScreenshotLoader.errorHandler', Log.ERROR);
			// if screenshot fails to load, continue in the playback anyway
			controller.dispatchEvent(new ModelEvent(ModelEvent.SCREENSHOT_COMPLETE));
		}

		private function registerEventListeners() : void {
			if (loader) {
				loader.contentLoaderInfo.addEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				loader.contentLoaderInfo.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			}
		}

		private function unregisterEventListeners() : void {
			if (loader) {
				loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, completeHandler);
				loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, errorHandler);
				loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
				loader.contentLoaderInfo.removeEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			}
		}
	}
}