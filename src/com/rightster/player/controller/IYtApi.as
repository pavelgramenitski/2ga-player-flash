package com.rightster.player.controller {
	import com.rightster.player.model.IPlaylist;
	import flash.events.IEventDispatcher;
	
	/**
	 * @author Daniel
	 */
	public interface IYtApi extends IEventDispatcher {
		
		//*** YouTube API *** (https://developers.google.com/youtube/flash_api_reference)
		
		//*** Queueing functions ***
		
		function cueVideoById(initObject : Object) : void;
		
		function loadVideoById(initObject : Object) : void;
		
		//function cueVideoByUrl(mediaContentUrl:String, startSeconds:Number, suggestedQuality:String):Void
		
		//function loadVideoByUrl(mediaContentUrl:String, startSeconds:Number, suggestedQuality:String):Void
		
		function cuePlaylist(initObject : Object) : void
		
		function loadPlaylist(initObject : Object): void
		
		//*** Playback controls and player settings ***
		
		function playVideo() : void;
		
		function pauseVideo() : void;
		
		function stopVideo() : void;
		
		function seekTo(seconds : Number, allowSeekAhead : Boolean) : void;
		
		//*** Playing a video in a playlist
		
		function nextVideo() : void;
		
		function previousVideo() : void;
		
		function playVideoAt(index : Number) : void;
		
		//*** Changing the player volume
		
		function mute() : void;
		
		function unMute() : void;
		
		function isMuted() : Boolean;
		
		function setVolume(volume : Number) : void;
		
		function getVolume() : Number;
		
		//*** Setting the player size
		
		function setSize(width : Number, height : Number) : void;
		
		//*** Setting playback behavior for playlists
		
		function setLoop(loopPlaylists : Boolean) : void;
		
		function setShuffle(shufflePlaylist : Boolean) : void;
		
		//*** Playback status ***
		
		function getVideoBytesLoaded() : Number;
		
		function getVideoBytesTotal() : Number;
		
		function getVideoStartBytes() : Number
		
		function getPlayerState() : Number;
		
		function getCurrentTime() : Number;
		
		//*** Playback quality ***
		
		function getPlaybackQuality() : String; 
		
		function setPlaybackQuality(suggestedQuality : String) : void;
		
		function getAvailableQualityLevels() : Array;
		
		//*** video information and playlist information ***
		
		function getDuration() : Number; 
		
		function getVideoUrl() : String; //landing page
		
		function getVideoEmbedCode() : String; 
		
		function getPlaylist() : IPlaylist;
		
		function getPlaylistIndex() : Number;
	}
}
