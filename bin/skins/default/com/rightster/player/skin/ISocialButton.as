package com.rightster.player.skin {
	/**
	 * @author kenrutherford
	 */
	public interface ISocialButton {
		function show() : void;

		function hide() : void;

		function dispose() : void;

		function sharingIsValid() : Boolean;
	}
}
