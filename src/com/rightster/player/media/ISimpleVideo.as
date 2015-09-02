package com.rightster.player.media {
	/**
	 * @author Daniel
	 */
	public interface ISimpleVideo {
		
		function playVideo() : void;
		
		function pauseVideo() : void;
		
		function stopVideo() : void;
				
		function seekTo(seconds : Number, allowSeekAhead : Boolean) : void;
		
		function getCurrentTime() : Number;
		
		function getDuration() : Number;	
		
		function dispose() : void
		
		function set muted(b : Boolean) : void;
		
		function set volume(n : Number) : void;
		
	}
}
