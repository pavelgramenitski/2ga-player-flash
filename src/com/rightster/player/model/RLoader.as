package com.rightster.player.model {
	import com.rightster.utils.AssetLoader;
	import com.rightster.player.controller.IController;
	import com.rightster.utils.Log;
	import flash.utils.Dictionary;
	import flash.events.ErrorEvent;
	import flash.system.LoaderContext;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	
	/**
	 * @author Arun
	 */
	public class RLoader extends EventDispatcher {		
		private var controller : IController;
		private var loaders : Dictionary;
		private var forceSecure : Boolean; 
		
		public function RLoader(controller : IController, forceSecure : Boolean = false) {
			this.controller = controller;
			this.forceSecure = forceSecure;
			
			loaders = new Dictionary();
		}
		
		public function load(request : URLRequest, assetType : String, context : LoaderContext, blocking : Boolean, errorCode : String, errorMessage : String, callbackSuccess : Function, callbackFail : Function = null) : void {			
			
			if (forceSecure) {
				request.url = request.url.replace("http:", "https:");
			}
			
			var loader : AssetLoader = new AssetLoader();
			loader.addEventListener(Event.COMPLETE, setData);
			loader.addEventListener(ErrorEvent.ERROR, getError);
			loaders[request.url] = loader;
			
			loader.load(request, assetType, context, blocking, errorCode, errorMessage, callbackSuccess, callbackFail);
		}
		
		public function reset() : void {
			for (var url : String in loaders) {
				var loader : AssetLoader = loaders[url];
				disposeLoader(loader);
			}
		}
		
		private function disposeLoader(ldr : AssetLoader) : void {
			ldr.removeEventListener(Event.COMPLETE, setData);
			ldr.removeEventListener(ErrorEvent.ERROR, getError);
			delete loaders[ldr.request.url];
			ldr.dispose();
		}
		
		private function getError(event : ErrorEvent) : void {
			var loader : AssetLoader = event.target as AssetLoader;
			
			loader.errorMessage += "url : " + loader.request.url + ", error text  : " + event.text;
			handleError(loader);
			
			disposeLoader(loader);
		}
		
		private function handleError(loader : AssetLoader) : void {			
			Log.write("RLoader.handleError * code : " + loader.errorCode + ", message : " + loader.errorMessage, Log.ERROR);
			
			controller.error(loader.errorCode, loader.errorMessage, loader.blocking);
			
			var callbackFail : Function = loader.callbackFail;
			
			if (String(callbackFail) != "null") {
				callbackFail();
			}
		}
		
		private function setData(event : Event) : void {
			var loader : AssetLoader = event.target as AssetLoader;

			switch(loader.type) {
				case AssetLoader.TYPE_SWF :
				case AssetLoader.TYPE_IMG :
					try {
						loader.callbackSuccess(loader.loadedObject);
					}
					catch (error : Error) {
						Log.write("RLoader.setData * message : " + error.message, Log.ERROR);
						handleError(loader);
					}
				break;
				
				case AssetLoader.TYPE_XML :
					try {
						var result : XML = new XML(loader.loadedObject); 
					}
					catch (error : Error) {
						Log.write("RLoader.setData * " + loader.request.url + " XML parsing error : " + error.message, Log.ERROR);
						handleError(loader);
					}
					
					try {
						loader.callbackSuccess(result);
					}
					catch (error : Error) {
						Log.write("RLoader.setData * message : " + error.message, Log.ERROR);
						handleError(loader);
					}
					
				break;
				
				case AssetLoader.TYPE_TEXT :
					try {
						loader.callbackSuccess(new String(loader.loadedObject));
					}
					catch (error : Error) {
						Log.write("RLoader.setData * error in  setting text response : " + error.message, Log.ERROR);
						handleError(loader);
					}
				break;
			}
			
			Log.write("RLoader.setData * load complete URL : " + loader.request.url + ", rtt : " + loader.rtt, Log.NET);
			
			disposeLoader(loader);
		}
	}
}
