package com.rightster.player.media {
	
	/**
	 * @author Daniel
	 */
	public interface IMediaProvider extends ISimpleVideo {
	
		function getVideoBytesLoaded() : Number;
		
		function getVideoBytesTotal() : Number;
		
		function getVideoStartBytes() : Number
		
		function setPlaybackQuality(suggestedQuality:String) : void;
		
		function getPlaybackQuality() : String; 
		
		function getPlaybackQualityIndex() : int;
		
		function set streamLatency(n : Number) : void;
		 
		function get streamLatency() : Number; 
		
		function get netConnection() : Object;
		
		function get netStream() : Object;
		
		function set autoSelectQuality(b:Boolean) : void;
	}
}
