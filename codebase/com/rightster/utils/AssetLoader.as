package com.rightster.utils {
	import flash.utils.getTimer;
	import flash.net.URLRequest;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.system.LoaderContext;
	import flash.display.LoaderInfo;
	import flash.display.Loader;
	import flash.events.HTTPStatusEvent;
	import flash.events.ErrorEvent;
	import flash.events.IOErrorEvent;
	import flash.events.Event;
	import flash.events.SecurityErrorEvent;
	import flash.events.EventDispatcher;

	/**
	 * @author Arun
	 */
	public class AssetLoader extends EventDispatcher {
		public static const TYPE_IMG : String = "image";
		public static const TYPE_SWF : String = "swf";
		public static const TYPE_XML : String = "xml";
		public static const TYPE_TEXT : String = "text";
		public var loadedObject : *;
		public var request : URLRequest;
		public var type : String;
		public var blocking : Boolean;
		public var errorCode : String;
		public var errorMessage : String;
		public var callbackSuccess : Function;
		public var callbackFail : Function;
		public var rtt : int;
		private var _loader : Loader;
		private var _urlLoader : URLLoader;
		private var tmp : int;

		public function load(request : URLRequest, type : String, context : LoaderContext, blocking : Boolean, errorCode : String, errorMessage : String, callbackSuccess : Function, callbackFail : Function = null) : void {
			Log.write("AssetLoader.load * url : " + request.url + " type: " + type + " Request: " + request, Log.NET);

			this.request = request;
			this.type = type;
			this.blocking = blocking;
			this.errorCode = errorCode;
			this.errorMessage = errorMessage;
			this.callbackSuccess = callbackSuccess;
			this.callbackFail = callbackFail;

			tmp = getTimer();

			if (type == TYPE_SWF || type == TYPE_IMG) {
				useLoader(request, context);
			} else {
				useURLLoader(request);
			}
		}

		public function dispose() : void {
			Log.write("AssetLoader.dispose * url : " + request.url, Log.NET);

			if (_loader) {
				try {
					_loader.unload();
				} catch (e : Error) {
					Log.write("AssetLoader.dispose * cannot unload url : " + request.url, Log.ERROR);
				}
				_loader.contentLoaderInfo.removeEventListener(Event.COMPLETE, loadComplete);
				_loader.contentLoaderInfo.removeEventListener(IOErrorEvent.IO_ERROR, dispatchError);
				_loader.contentLoaderInfo.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchError);
				_loader = null;
			} else if (_urlLoader) {
				Log.write("AssetLoader.dispose * _urlLoader url : " + request.url, Log.NET);

				if (_urlLoader.hasEventListener(Event.COMPLETE)) {
					_urlLoader.removeEventListener(Event.COMPLETE, urlLoadComplete);
				}

				if (_urlLoader.hasEventListener(IOErrorEvent.IO_ERROR)) {
					_urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, dispatchError);
				}

				if (_urlLoader.hasEventListener(HTTPStatusEvent.HTTP_STATUS)) {
					_urlLoader.removeEventListener(HTTPStatusEvent.HTTP_STATUS, loadStatus);
				}

				if (_urlLoader.hasEventListener(SecurityErrorEvent.SECURITY_ERROR)) {
					_urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchError);
				}

				_urlLoader = null;
			}
		}

		private function useLoader(request : URLRequest, context : LoaderContext) : void {
			try {
				loader.load(request, context);
			} catch(e : Error) {
				dispatchError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, e.message));
			}
		}

		private function useURLLoader(request : URLRequest) : void {
			try {
				urlLoader.load(request);
			} catch(e : Error) {
				dispatchError(new SecurityErrorEvent(SecurityErrorEvent.SECURITY_ERROR, false, false, e.message));
			}
		}

		private function loadComplete(evt : Event) : void {
			rtt = getTimer() - tmp;
			try {
				loadedObject = (evt.target as LoaderInfo).content;
				dispatchEvent(new Event(Event.COMPLETE));
			} catch (e : Error) {
				dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}

		private function urlLoadComplete(evt : Event) : void {
			rtt = getTimer() - tmp;
			try {
				loadedObject = (evt.target as URLLoader).data;
				dispatchEvent(new Event(Event.COMPLETE));
			} catch (e : Error) {
				dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, e.message));
			}
		}

		private function loadStatus(event : HTTPStatusEvent) : void {
			Log.write('Assetloader.loadStatus *event' + event);

			switch (event.status) {
				case 400:
					dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Bad request."));
					break;
				case 401:
					dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Request not authorize."));
					break;
				case 403:
					dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, "File could not be loaded due to server permissions."));
					break;
				case 404:
					dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, "File not found."));
					break;
				case 500:
					dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Internal server error."));
					break;
				case 503:
					dispatchError(new ErrorEvent(ErrorEvent.ERROR, false, false, "Service unavailable."));
					break;
			}
		}

		private function dispatchError(evt : ErrorEvent) : void {
			if (evt is SecurityErrorEvent) {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, "Crossdomain loading denied."));
			} else {
				dispatchEvent(new ErrorEvent(ErrorEvent.ERROR, false, false, evt.text));
			}
		}

		private function get loader() : Loader {
			if (!_loader) {
				_loader = new Loader();
				_loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);
				_loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, dispatchError);
				_loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchError);
			}
			return _loader;
		}

		private function get urlLoader() : URLLoader {
			try {
				if (!_urlLoader) {
					_urlLoader = new URLLoader();
					_urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
					_urlLoader.addEventListener(Event.COMPLETE, urlLoadComplete);
					_urlLoader.addEventListener(IOErrorEvent.IO_ERROR, dispatchError);
					_urlLoader.addEventListener(HTTPStatusEvent.HTTP_STATUS, loadStatus);
					_urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, dispatchError);
				}
			} catch(error : Error) {
				Log.write(error.message);
			}

			return _urlLoader;
		}
	}
}
