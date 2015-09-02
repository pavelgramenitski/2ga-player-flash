package com.rightster.player.platform {
	import com.rightster.player.model.IPlaylist;

	/**
	 * @author Daniel
	 */
	public interface IPlatform {
		function get playlist() : IPlaylist;

		function getServiceUrl() : String;

		function loadPlaylist(id : String = "") : void;

		function loadVideo(id : String) : void;

		function loadGUID() : void;

		function requestPlaybackAuth() : void;

		function dispose() : void;
	}
}
