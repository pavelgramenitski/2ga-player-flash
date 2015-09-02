package com.rightster.player.controller {
	import com.rightster.player.model.JsApi;
	import com.rightster.player.platform.IPlatform;
	import com.rightster.player.view.IColors;
	import com.rightster.player.model.RLoader;
	import com.rightster.player.model.MetaStream;
	import com.rightster.player.model.Config;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.MetaPlacement;
	import com.rightster.player.model.MetaVideo;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.Stage;

	/**
	 * @author Daniel
	 */
	public interface IController extends IYtApi {
		// *** Internal functions ***
		function get playerState() : int;

		function get width() : Number;

		function get height() : Number;

		function get fullScreen() : Boolean;

		function set fullScreen(b : Boolean) : void;

		function get config() : Config;

		function get placement() : MetaPlacement;

		function get live() : Boolean;

		function get video() : MetaVideo;

		function get flashVars() : Object;

		function get stream() : MetaStream;

		function get stage() : Stage;

		function get screen() : Sprite;

		function get version() : String;

		function get loader() : RLoader;

		function get loopMode() : String;

		function set loopMode(loopMode : String) : void;

		function setLoopMode(value : Number) : void;	// 0,1,2

		function initialize() : void;

		function addPlugin(plugin : IPlugin, layer : int) : void;

		function addScreenshot(loader : DisplayObject) : void;

		function addVideoScreen(video : DisplayObject) : void;

		function removeVideoScreen(video : DisplayObject) : void;

		function shareTwitter() : void;

		function shareFacebook() : void;

		function shareTumblr() : void;

		function shareEmail() : void;

		function shareGPlus() : void;

		function set streamLatency(n : Number) : void;

		function get streamLatency() : Number;

		function get netConnection() : Object;

		function get netStream() : Object;

		function error(code : String, message : String, blocking : Boolean = false) : void;

		function get colors() : IColors;

		function set colors(value : IColors) : void;

		function get currentProtocol() : String;

		function set currentProtocol(value : String) : void;

		function setDirtyPlacementValue(key : String, value : *) : void ;

		function applyDirtyPlacementValues() : void;

		function clearDirtyPlacementValues() : void;

		function get placementValuesAreDirty() : Boolean;

		function get platform() : IPlatform;
		
		function get jsApi() : JsApi 
	}
}
