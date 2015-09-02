package com.rightster.player.model {	
	import com.rightster.utils.AssetLoader;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ModelEvent;
	import com.rightster.utils.Log;
	
	import flash.display.LoaderInfo;
	import flash.utils.Dictionary;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.system.SecurityDomain;
	
	/**
	 * @author Daniel
	 */
	public class PluginLoader {		
		private var controller : IController;
		
		private var _plugins : Array;
		private var _metaPluginsD : Dictionary;
		private var _pluginsD : Dictionary;
		private var _queueLength : uint;
		private var securityDomain : SecurityDomain;
		
		public function PluginLoader(controller : IController) : void {
			this.controller = controller;
			
			_metaPluginsD = new Dictionary();
			_pluginsD = new Dictionary();
			
			if (controller.live) {
				securityDomain = SecurityDomain.currentDomain;
			} else {
				securityDomain = null;
			}
		}
		
		public function get pluginList() : Array {
			return _plugins;
		}
		
 		public function dispose() : void {			
			for each (var plugin : IPlugin in _plugins) {
				Log.write("PluginLoader.dispose * " + plugin, Log.DATA);
				plugin.dispose();
			}
			_plugins = [];
		}
		
		public function load(plugins : Array) : void {
			Log.write("PluginLoader.load");
			
			if (plugins.length > 0) {
				_plugins = [];
				_queueLength = plugins.length;
				for each (var metaPlugin : MetaPlugin in plugins) {
					loadLocalPlugin(metaPlugin);
				}
			}
			else {
				controller.dispatchEvent(new ModelEvent(ModelEvent.PLUGINS_COMPLETE));
			}
		}
		
		private function loadLocalPlugin(metaPlugin : MetaPlugin) : void {
			Log.write("PluginLoader.loadLocalPlugin * plugin url : " + metaPlugin.url, Log.DATA);
			
			if (_metaPluginsD.hasOwnProperty(metaPlugin.url)) {				
				var plugin : IPlugin = _pluginsD[metaPlugin.url] as IPlugin;
				plugin.initialize(controller, metaPlugin.data);
				_plugins.push(plugin);
				_queueLength--;
				checkComplete();
			}
			else {				
				var url : String = controller.live == true ? (controller.placement.path + metaPlugin.url + "?auth=" + controller.placement.authValue) : (controller.placement.path + metaPlugin.url);
				var request : URLRequest = new URLRequest(url);
				controller.loader.load(request, AssetLoader.TYPE_IMG,  new LoaderContext(false, ApplicationDomain.currentDomain, securityDomain), true, ErrorCode.ASSET_LOADING_ERROR, "PluginLoader.load * ", loadSuccess);
				_metaPluginsD[metaPlugin.url] = metaPlugin;
			}
		}

		private function loadSuccess(data : *) : void {
			var url : String = (data.loaderInfo as LoaderInfo).url;
			Log.write("PluginLoader.loadSuccess * url : " + url, Log.DATA);			
			
			var urlArr : Array = (url.split("?")[0]).split("/");
			
			var pluginUrl : String = urlArr[urlArr.length-2] + "/" + urlArr[urlArr.length-1];
			
			Log.write("PluginLoader.loadSuccess * plugin url : " + pluginUrl, Log.DATA);
			
			var isError : Boolean;
			try {
				var plugin : IPlugin = data as IPlugin;
				_plugins.push(plugin);
				_pluginsD[pluginUrl] = plugin;
				plugin.initialize(controller, _metaPluginsD[pluginUrl].data);
			} catch (err : Error) {
				isError = true;
				controller.error(ErrorCode.PLUGIN_INTEGRITY_ERROR, "PluginLoader.loadSuccess Error * " + err.message + " * url: " + pluginUrl, true);
				if (!controller.live) throw(err);
			}
			
			if (!isError && plugin.zIndex != PluginZindex.NONE) {
				controller.addPlugin(plugin, plugin.zIndex);
			}
			
			_queueLength--;
			
			checkComplete();
		}
		
		private function checkComplete() : void {
			if (_queueLength <= 0) {
				controller.dispatchEvent(new ModelEvent(ModelEvent.PLUGINS_COMPLETE));
			}
		}
	}
}