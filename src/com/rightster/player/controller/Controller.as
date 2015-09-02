package com.rightster.player.controller {
	import com.rightster.player.Version;
	import com.rightster.player.events.ErrorEvent;
	import com.rightster.player.events.LoopModeEvent;
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.model.Config;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.JsApi;
	import com.rightster.player.model.LoopMode;
	import com.rightster.player.model.MetaPlacement;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.model.Model;
	import com.rightster.player.model.RLoader;
	import com.rightster.player.platform.IPlatform;
	import com.rightster.player.view.IColors;
	import com.rightster.player.view.View;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.utils.Dictionary;

	/**
	 * @author Daniel
	 */
	public class Controller extends YtApi implements IController {
		private var dirtyPlacementValueRegistry : Dictionary;
		private var _placementValuesAreDirty : Boolean;

		public function pluginsNeedDisplay() : void {
			var event : PluginEvent = new PluginEvent(PluginEvent.REFRESH);
			this.dispatchEvent(event);
		}

		public function get playerState() : int {
			return model.playerState;
		}

		public function get width() : Number {
			return view.width;
		}

		public function get height() : Number {
			return view.height;
		}

		public function get fullScreen() : Boolean {
			return view.fullScreen;
		}

		public function set fullScreen(b : Boolean) : void {
			view.fullScreen = b;
		}

		public function get config() : Config {
			return model.config;
		}

		public function get placement() : MetaPlacement {
			return model.placement;
		}

		public function get stage() : Stage {
			return view.stage;
		}

		public function get screen() : Sprite {
			return view.screen;
		}

		public function get live() : Boolean {
			return model.live;
		}

		// shortcut to the current video
		public function get video() : MetaVideo {
			return model.video;
		}

		public function get flashVars() : Object {
			return model.flashVars;
		}

		public function get version() : String {
			return Version.VERSION;
		}

		public function set streamLatency(n : Number) : void {
			if (model.mediaProvider != null) {
				model.mediaProvider.streamLatency = n;
			}
		}

		public function get streamLatency() : Number {
			if (model.mediaProvider != null) {
				return model.mediaProvider.streamLatency;
			} else {
				return 0;
			}
		}

		public function get netConnection() : Object {
			if (model.mediaProvider != null) {
				return model.mediaProvider.netConnection;
			} else {
				return null;
			}
		}

		public function get netStream() : Object {
			if (model.mediaProvider != null) {
				return model.mediaProvider.netStream;
			} else {
				return null;
			}
		}

		public function get loader() : RLoader {
			return model.loader;
		}

		public function get loopMode() : String {
			return model.playlist.loopMode;
		}

		public function set loopMode(loopMode : String) : void {
			model.playlist.loopMode = loopMode;
			dispatchEvent(new LoopModeEvent(LoopModeEvent.CHANGE));
		}

		public function get platform() : IPlatform {
			return model.platform;
		}

		public function Controller(model : Model, view : View) {
			super(this, model, view);
		}

		public function initialize() : void {
			view.initialize(this);

			model.initialize(this);

			model.connectToPlatform();
		}

		public function addPlugin(plugin : IPlugin, layer : int) : void {
			view.addPlugin(plugin, layer);
		}

		public function addScreenshot(child : DisplayObject) : void {
			view.addScreenshot(child);
		}

		public function addVideoScreen(child : DisplayObject) : void {
			view.addVideoScreen(child);
		}

		public function removeVideoScreen(child : DisplayObject) : void {
			if (child ) {
				view.removeVideoScreen(child);
			}
		}

		public function setDirtyPlacementValue(key : String, value : *) : void {
			if (!dirtyPlacementValueRegistry) {
				dirtyPlacementValueRegistry = new Dictionary();
				_placementValuesAreDirty = true;
			}

			dirtyPlacementValueRegistry[key] = value;
		}

		public function applyDirtyPlacementValues() : void {
			for (var key : String in dirtyPlacementValueRegistry) {
				if (placement.hasOwnProperty(key)) {
					placement[key] = dirtyPlacementValueRegistry[key];
				}
			}

			clearDirtyPlacementValues();
		}

		public function clearDirtyPlacementValues() : void {
			for (var key : String in dirtyPlacementValueRegistry) {
				dirtyPlacementValueRegistry[key] = null;
				delete dirtyPlacementValueRegistry[key];
			}

			dirtyPlacementValueRegistry = null;
			_placementValuesAreDirty = false;
		}

		public function get placementValuesAreDirty() : Boolean {
			return _placementValuesAreDirty;
		}

		public function error(code : String, message : String, blocking : Boolean = false) : void {
			view.errorScreen.error(code, message, blocking);
			model.error(code, message, blocking);

			// surface the error to public api
			var data : Object = {};
			data.code = code;
			data.message = message;
			data.blocking = blocking;
			var errorEvent : ErrorEvent = new ErrorEvent(ErrorEvent.ERROR, data);
			dispatchEvent(errorEvent);
		}

		// shortcut to the current stream
		public function get stream() : MetaStream {
			return model.stream;
		}

		public function shareTwitter() : void {
			model.shareTwitter();
		}

		public function shareFacebook() : void {
			model.shareFacebook();
		}

		public function shareTumblr() : void {
			model.shareTumblr();
		}

		public function shareEmail() : void {
			model.shareEmail();
		}

		public function shareGPlus() : void {
			model.shareGPlus();
		}

		public function get colors() : IColors {
			return model.colors;
		}

		public function set colors(value : IColors) : void {
			model.colors = value;
		}

		public function get currentProtocol() : String {
			return model.currentProtocol;
		}

		public function set currentProtocol(value : String) : void {
			model.currentProtocol = value;
		}

		public function get jsApi() : JsApi {
			return model.jsApi;
		}

		public function setLoopMode(value : Number) : void {
			var loopModeToSet : String;
			switch(value) {
				case 0:
					loopModeToSet = LoopMode.NONE;
					break;
				case 1:
					loopModeToSet = LoopMode.PLAYLIST;
					break;
				case 2:
					loopModeToSet = LoopMode.VIDEO;
					break;
				default:
					loopModeToSet = LoopMode.NONE;
			}

			loopMode = loopModeToSet;
		}
	}
}
