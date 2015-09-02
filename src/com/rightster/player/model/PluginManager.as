package com.rightster.player.model {
	import com.rightster.utils.AssetLoader;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ModelEvent;
	import com.rightster.utils.Log;
	import com.rightster.player.model.PluginManagerItem;

	import flash.display.LoaderInfo;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;

	/**
	 * @author KJR
	 */
	public class PluginManager {
		private var controller : IController;
		private var _activePlugins : Array;
		private var registry : Dictionary;
		private var queueLength : uint;
		private var securityDomain : SecurityDomain;
		private var initialized : Boolean;

		public function PluginManager(controller : IController) : void {
			Log.write("PluginManager.constructor");
			if (!initialized) {
				initialize(controller);
			}
		}

		/*
		 * PUBLIC METHODS 
		 */
		public function dispose() : void {
			Log.write("PluginManager.dispose");
			disposeActivePlugins();
			_activePlugins = null;
			unregisterAllPluginItems();
			registry = null;
			initialized = false;
			queueLength = 0;
			controller = null;
			securityDomain = null;
		}

		public function closeActivePlugins() : void {
			Log.write("PluginManager.closeActivePlugins");

			var success : Boolean = false;
			for each (var plugin : IPlugin in _activePlugins) {
				Log.write("PluginManager closing... * " + plugin, Log.DATA);
				try {
					plugin.close();
					success = true;
				} catch(error : Error) {
					Log.write("PluginManager.closeActivePlugins * error:" + error.toString(), Log.ERROR);
				}
			}

			if (!success) {
				Log.write("PluginManager.closeActivePlugins * No active plugins to close");
			}

			_activePlugins = [];
		}

		public function disposeActivePlugins() : void {
			for each (var plugin : IPlugin in _activePlugins) {
				Log.write("PluginManager.disposeActivePlugins * " + plugin, Log.DATA);
				plugin.dispose();
			}

			_activePlugins = [];
		}

		public function runPlugins(arr : Array) : void {
			Log.write("PluginManager.runPlugins");
			if (arr.length > 0) {
				_activePlugins = [];
				queueLength = arr.length;

				for each (var metaPlugin : MetaPlugin in arr) {
					runPlugin(metaPlugin);
				}
			} else {
				controller.dispatchEvent(new ModelEvent(ModelEvent.PLUGINS_COMPLETE));
			}
		}

		/*
		 * GETTERS/SETTERS
		 */
		public function get activePlugins() : Array {
			return _activePlugins;
		}

		/*
		 * EVENT HANDLERS
		 */
		private function loadSuccessHandler(data : *) : void {
			var url : String = (data.loaderInfo as LoaderInfo).url;
			Log.write("PluginManager.loadSuccessHandler * url : " + url, Log.DATA);
			var pluginUrl : String = determinePluginUrl(url);

			var isError : Boolean;
			try {
				var plugin : IPlugin = data as IPlugin;
				_activePlugins.push(plugin);
				registerPlugin(pluginUrl, plugin);
				plugin.initialize(controller, registry[pluginUrl].metaPlugin.data);
			} catch (error : Error) {
				isError = true;
				controller.error(ErrorCode.PLUGIN_INTEGRITY_ERROR, "PluginManager.loadSuccess Error * " + error.message + " * url: " + pluginUrl, true);
				unregisterPluginItemWithUrlKey(pluginUrl);

				if (!controller.live) {
					throw(error);
				}
			}

			if (!isError && plugin.zIndex != PluginZindex.NONE) {
				// ok to add plugin to the view via the controller
				controller.addPlugin(plugin, plugin.zIndex);
			}

			queueLength--;
			checkComplete();
		}

		/*
		 * PRIVATE METHDOS
		 */
		private function initialize(controller : IController) : void {
			Log.write("PluginManager.initialize");
			this.controller = controller;
			registry = new Dictionary();

			if (controller.live) {
				securityDomain = SecurityDomain.currentDomain;
			} else {
				securityDomain = null;
			}

			initialized = true;
		}

		private function runPlugin(metaPlugin : MetaPlugin) : void {
			Log.write("PluginManager.runPlugin * plugin url : " + metaPlugin.url, Log.DATA);
			if (isRegisteredMetaPlugin(metaPlugin)) {
				runRegisteredPlugin(metaPlugin);
			} else {
				loadUnregisteredPlugin(metaPlugin);
			}
		}

		private function runRegisteredPlugin(metaPlugin : MetaPlugin) : void {
			Log.write("PluginManager.runRegisteredPlugin * plugin url : " + metaPlugin.url, Log.DATA);
			var plugin : IPlugin = (registry[metaPlugin.url] as PluginManagerItem).plugin;
			if (!plugin.initialized) {
				plugin.initialize(controller, metaPlugin.data);
			} else {
				plugin.run(metaPlugin.data);
			}

			_activePlugins.push(plugin);
			queueLength--;
			checkComplete();
		}

		private function loadUnregisteredPlugin(metaPlugin : MetaPlugin) : void {
			Log.write("PluginManager.loadUnregisteredPlugin * plugin url : " + metaPlugin.url, Log.DATA);
			var url : String = controller.live == true ? (controller.placement.path + metaPlugin.url + "?auth=" + controller.placement.authValue) : (controller.placement.path + metaPlugin.url);
			var request : URLRequest = new URLRequest(url);

			// create item and register
			var item : PluginManagerItem = new PluginManagerItem(metaPlugin);
			registerPluginManagerItem(item);

			controller.loader.load(request, AssetLoader.TYPE_IMG, new LoaderContext(false, ApplicationDomain.currentDomain, securityDomain), true, ErrorCode.ASSET_LOADING_ERROR, "PluginManager.load * ", loadSuccessHandler);
		}

		private function checkComplete() : void {
			if (queueLength <= 0) {
				controller.dispatchEvent(new ModelEvent(ModelEvent.PLUGINS_COMPLETE));
			}
		}

		private function determinePluginUrl(url : String) : String {
			var urlArr : Array = (url.split("?")[0]).split("/");
			var pluginUrl : String = urlArr[urlArr.length - 2] + "/" + urlArr[urlArr.length - 1];
			return pluginUrl;
		}

		private function registerPluginManagerItem(item : PluginManagerItem) : void {
			Log.write("PluginManager.registerPluginManagerItem * item.url : " + item.metaPlugin.url, Log.DATA);
			var url : String = item.metaPlugin.url;

			if (!isRegisteredPluginItem(item)) {
				registry[url] = item;
			} else {
				Log.write("PluginManager.registerPluginManagerItem * ERROR plugin already registered : " + url, Log.ERROR);
			}
		}

		private function isRegisteredMetaPlugin(metaPlugin : MetaPlugin) : Boolean {
			if (registry.hasOwnProperty(metaPlugin.url)) {
				return true;
			}

			return false;
		}

		private function isRegisteredPluginItem(item : PluginManagerItem) : Boolean {
			if (registry.hasOwnProperty(item.metaPlugin.url)) {
				return true;
			}

			return false;
		}

		private function unregisterPluginItemWithUrlKey(key : String) : void {
			Log.write("PluginManager.unregisterMetaPluginWithUrlKey * key : " + key, Log.DATA);
			if (isRegisteredPluginItemWithUrlKey(key)) {
				registry[key] = null;
				delete registry[key];
			} else {
				Log.write("PluginManager.unregisterMetaPlugin * ERROR key not registered : " + key, Log.ERROR);
			}
		}

		private function isRegisteredPluginItemWithUrlKey(key : String) : Boolean {
			if (registry.hasOwnProperty(key)) {
				return true;
			}

			return false;
		}

		private function registerPlugin(key : String, plugin : IPlugin) : void {
			Log.write("PluginManager.registerPlugin" + key, Log.DATA);
			if (!isRegisteredPlugin(plugin)) {
				var item : PluginManagerItem = (registry[key] as PluginManagerItem);
				item.plugin = plugin;
				item.active = true;
			} else {
				Log.write("PluginManager.registerPlugin * ERROR plugin already registered : " + key, Log.ERROR);
			}
		}

		private function unregisterAllPluginItems() : void {
			Log.write("PluginManager.unregisterAllPluginItems");
			for (var key : String in registry) {
				var item : PluginManagerItem = (registry[key] as PluginManagerItem);
				item.metaPlugin = null;
				item.plugin = null;
				registry[key] = null;
				delete registry[key];
			}
		}

		private function isRegisteredPlugin(plugin : IPlugin) : Boolean {
			for (var key : String in registry) {
				var item : PluginManagerItem = (registry[key] as PluginManagerItem);
				var tmpPlugin : IPlugin = item.plugin;
				if (tmpPlugin == plugin) {
					return true;
				}
			}

			return false;
		}
	}
}