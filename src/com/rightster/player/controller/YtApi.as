package com.rightster.player.controller {
	import com.rightster.player.model.IPlaylist;
	import com.rightster.utils.Log;
	import com.rightster.player.model.Model;
	import com.rightster.player.view.View;

	import flash.events.EventDispatcher;

	/**
	 * @author Daniel
	 */
	public class YtApi extends EventDispatcher implements IYtApi {
		private var controller : IController;
		protected var model : Model;
		protected var view : View;

		public function YtApi(controller : IController, model : Model, view : View) : void {
			this.controller = controller;
			this.model = model;
			this.view = view;
		}

		// *** Queueing functions ***
		public function cueVideoById(initObject : Object) : void {
			initObject['autoplay'] = 0;
			Log.write("YtApi.cueVideoById : " + initObject.placementid);
			controller.getPlaylist().resetPlaylist();
			model.connectToPlatform(initObject);
		}

		public function loadVideoById(initObject : Object) : void {
			initObject['autoplay'] = 1;
			Log.write("YtApi.loadVideoById : " + initObject.placementid);
			controller.getPlaylist().resetPlaylist();
			model.connectToPlatform(initObject);
		}

		public function cuePlaylist(initObject : Object) : void {
			initObject['autoplay'] = 0;
			Log.write("YtApi.cuePlaylist : " + initObject.placementid);
			controller.getPlaylist().resetPlaylist();
			model.connectToPlatform(initObject);
		}

		public function loadPlaylist(initObject : Object) : void {
			initObject['autoplay'] = 1;
			Log.write("YtApi.loadPlaylist : " + initObject.placementid);
			controller.getPlaylist().resetPlaylist();
			model.connectToPlatform(initObject);
		}

		// *** Playback controls and player settings ***
		public function playVideo() : void {
			model.playVideoAt(-1);
		}

		public function pauseVideo() : void {
			model.simpleVideo.pauseVideo();
		}

		public function stopVideo() : void {
			model.simpleVideo.stopVideo();
		}

		public function seekTo(seconds : Number, allowSeekAhead : Boolean) : void {
			model.simpleVideo.seekTo(seconds, allowSeekAhead);
		}

		// *** Playing a video in a playlist
		public function nextVideo() : void {
			model.playlist.nextVideo();
		}

		public function previousVideo() : void {
			model.playlist.previousVideo();
		}

		public function playVideoAt(index : Number) : void {
			model.playVideoAt(index);
		}

		// *** Changing the player volume
		public function mute() : void {
			model.cookieManager.muted = true;
			model.simpleVideo.muted = true;
		}

		public function unMute() : void {
			model.cookieManager.muted = false;
			model.simpleVideo.muted = false;
			controller.placement.startMuted = false;
		}

		public function isMuted() : Boolean {
			return model.cookieManager.muted;
		}

		public function setVolume(volume : Number) : void {
			model.cookieManager.volume = volume;
			model.simpleVideo.volume = volume;
			controller.placement.startMuted = false;
		}

		public function getVolume() : Number {
			return model.cookieManager.volume;
		}

		// *** Setting the player size
		public function setSize(width : Number, height : Number) : void {
			//
		}

		// *** Setting playback behavior for playlists
		public function setLoop(loopPlaylists : Boolean) : void {
			Log.write("YtApi.setLoop : " + loopPlaylists);
		}

		public function setShuffle(shufflePlaylist : Boolean) : void {
			if (shufflePlaylist) {
				controller.getPlaylist().randomize();
			} else {
				controller.getPlaylist().restore();
			}
		}

		// *** Playback status ***
		public function getPlayerState() : Number {
			return model.playerState;
		}

		public function getVideoBytesLoaded() : Number {
			return model.mediaProvider == null ? 0 : model.mediaProvider.getVideoBytesLoaded();
		}

		public function getVideoBytesTotal() : Number {
			return model.mediaProvider == null ? 1 : model.mediaProvider.getVideoBytesTotal();
		}

		public function getVideoStartBytes() : Number {
			return model.mediaProvider == null ? 0 : model.mediaProvider.getVideoStartBytes();
		}

		public function getCurrentTime() : Number {
			return model.mediaProvider == null ? 0 : model.mediaProvider.getCurrentTime();
		}

		// *** Playback quality ***
		public function getPlaybackQuality() : String {
			return model.mediaProvider != null ? model.mediaProvider.getPlaybackQuality() : "";
		}

		public function setPlaybackQuality(suggestedQuality : String) : void {
			model.playbackQuality = suggestedQuality;
		}

		public function getAvailableQualityLevels() : Array {
			return model.availableQualityLevels;
		}

		// *** video information and playlist information ***
		public function getDuration() : Number {
			return model.mediaProvider == null ? 0 : model.mediaProvider.getDuration();
		}

		public function getVideoUrl() : String {
			return controller.video.playerShareUrl;
		}

		public function getVideoEmbedCode() : String {
			return model.getVideoEmbedCode();
		}

		public function getPlaylist() : IPlaylist {
			return model.playlist;
		}

		public function getPlaylistIndex() : Number {
			return model.playlistIndex;
		}
	}
}
