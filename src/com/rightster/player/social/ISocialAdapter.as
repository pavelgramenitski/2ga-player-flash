package com.rightster.player.social {
	import com.rightster.player.controller.IController;

	/**
	 * @author KJR
	 */
	public interface ISocialAdapter {
		
		function initialize(controller : IController) : void;

		function shareTwitter() : void;

		function shareFacebook() : void;

		function shareTumblr() : void;

		function shareEmail() : void;

		function shareGPlus() : void;

		function get type() : String;
	}
}
