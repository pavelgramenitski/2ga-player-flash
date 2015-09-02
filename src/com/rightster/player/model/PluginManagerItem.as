package com.rightster.player.model {
	import com.rightster.utils.Log;
	/**
	 * @author kenrutherford
	 */
	public class PluginManagerItem {
		
		
		public var metaPlugin:MetaPlugin;
		public var plugin:IPlugin;
		public var active:Boolean;
		
		public function PluginManagerItem(metaPlugin:MetaPlugin):void{
			this.metaPlugin = metaPlugin;
		}
		
		public function toString():String{
			var str:String = "MetaPlugin: " + metaPlugin.toString() + ", Plugin: " + plugin + ", active: " + active;
			Log.write(str);
			return str;
		}
	}
}
