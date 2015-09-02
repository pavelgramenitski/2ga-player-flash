package com.rightster.player.model {
	import com.rightster.player.controller.IController;

	/**
	 * @author Daniel
	 */
	public interface IPlugin {
		function initialize(controller : IController, data : Object) : void;

		function run(data : Object) : void;

		function close() : void;

		function dispose() : void;

		function get zIndex() : int;

		function get loaded() : Boolean;
		
		function get initialized() : Boolean;
	}
}