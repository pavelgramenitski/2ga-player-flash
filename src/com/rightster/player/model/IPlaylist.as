package com.rightster.player.model {
	/**
	 * @author Arun
	 */
	public interface IPlaylist {
		function resetPlaylist() : void;

		function getItemAt(idx : Number = -1) : MetaVideo;

		function insertItem(item : MetaVideo, idx : Number = -1) : void;

		function removeItemAt(idx : Number) : void;

		function contains(item : MetaVideo) : Boolean;

		function getList() : Array;

		function randomize() : void;

		function restore() : void;

		function get currentIndex() : Number;

		function set currentIndex(idx : Number) : void;

		function get currentItem() : MetaVideo;

		function get length() : Number;

		function get stream() : MetaStream;

		function get loopMode() : String;

		function set loopMode(value : String) : void;

		function nextVideo() : void;

		function previousVideo() : void;

		function get playlistIndex() : uint;

		function get video() : MetaVideo;

		function get playlist() : Array;

		function isLastVideo() : Boolean;
	}
}