package com.rightster.player.skin {
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.model.LoopMode;
	import com.rightster.player.controller.IController;
	import com.rightster.utils.Log;

	import flash.display.Sprite;

	/**
	 * @author KJR
	 */
	public class PlaylistBar extends Sprite {
		private var controller : IController;
		private var playlistBarViewControl : PlaylistBarViewControl;
		private var playlistBarVideoTitle : PlaylistBarVideoTitle;
		private var playlistBarLoopListButton : PlaylistBarLoopButton;
		private var _width : Number = 0;

		/*
		 * Contructor
		 */
		public function PlaylistBar(controller : IController) {
			this.controller = controller;

			createChildren();
			setInitialDisplayState();
			registerEventListeners();
		}

		/*
		 * PUBLIC METHODS
		 */
		public function dispose() : void {
			removeChild(playlistBarViewControl);
			removeChild(playlistBarLoopListButton);
			removeChild(playlistBarVideoTitle);

			playlistBarViewControl.dispose();
			playlistBarLoopListButton.dispose();
			playlistBarVideoTitle.dispose();

			playlistBarViewControl = null;
			playlistBarLoopListButton = null;
			playlistBarVideoTitle = null;

			unregisterEventListeners();
			controller = null;
		}

		/*
		 * GETTER/SETTERS
		 */
		override public function set width(w : Number) : void {
			_width = w;
			layout();
		}

		/*
		 * EVENT HANDLERS
		 */
		private function handleLoopButtonEvent(event : LoopButtonEvent) : void {
			Log.write('PlaylistBar.handleLoopButtonEvent * ' + event.type);

			switch (event.type) {
				case LoopButtonEvent.LOOP_VIDEO:
					controller.loopMode = LoopMode.VIDEO;
					break;
				case LoopButtonEvent.LOOP_LIST:
					controller.loopMode = LoopMode.PLAYLIST;
					break;
				default:
					controller.loopMode = LoopMode.NONE;
			}
		}

		private function handlePlayListViewEvent(event : PlaylistViewEvent) : void {
			Log.write('PlaylistBar.handlePlayListViewEvent * ' + event.type);
			if (event.type == PlaylistViewEvent.SHOW) {
				this.visible = true;
				this.alpha = 1;
			}
		}

		private function handlePluginRefreshEvent(event : PluginEvent) : void {
			updateViewControlDisplay();
		}

		/*
		 * PRIVATE METHODS
		 */
		private function createChildren() : void {
			playlistBarViewControl = new PlaylistBarViewControl(controller);
			addChild(playlistBarViewControl);
			playlistBarViewControl.x = 0;
			playlistBarViewControl.y = 0;

			playlistBarLoopListButton = new PlaylistBarLoopButton(controller);
			addChild(playlistBarLoopListButton);
			playlistBarLoopListButton.x = _width - playlistBarLoopListButton.width;
			playlistBarLoopListButton.y = 0;

			playlistBarVideoTitle = new PlaylistBarVideoTitle(controller);
			addChild(playlistBarVideoTitle);
			playlistBarVideoTitle.x = playlistBarViewControl.x + playlistBarViewControl.width;
			playlistBarVideoTitle.y = 0;
			playlistBarVideoTitle.width = playlistBarLoopListButton.x - playlistBarVideoTitle.x;
		}

		private function setInitialDisplayState() : void {
			updateViewControlDisplay();
		}

		private function layout() : void {
			playlistBarLoopListButton.x = _width - playlistBarLoopListButton.width;
			playlistBarVideoTitle.x = playlistBarViewControl.x + playlistBarViewControl.width;
			playlistBarVideoTitle.width = _width - playlistBarLoopListButton.width - playlistBarVideoTitle.x;
		}

		private function updateViewControlDisplay() : void {
			var index : int = controller.getPlaylistIndex();
			var total : int = controller.getPlaylist().length;
			var str : String = index + 1 + " of " + total + " videos";

			playlistBarViewControl.displayText = str;
		}

		private function registerEventListeners() : void {
			controller.addEventListener(LoopButtonEvent.LOOP_INACTIVE, handleLoopButtonEvent);
			controller.addEventListener(LoopButtonEvent.LOOP_LIST, handleLoopButtonEvent);
			controller.addEventListener(LoopButtonEvent.LOOP_VIDEO, handleLoopButtonEvent);
			controller.addEventListener(PlaylistViewEvent.SHOW, handlePlayListViewEvent);
			controller.addEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}

		private function unregisterEventListeners() : void {
			controller.removeEventListener(LoopButtonEvent.LOOP_INACTIVE, handleLoopButtonEvent);
			controller.removeEventListener(LoopButtonEvent.LOOP_LIST, handleLoopButtonEvent);
			controller.removeEventListener(LoopButtonEvent.LOOP_VIDEO, handleLoopButtonEvent);
			controller.removeEventListener(PlaylistViewEvent.SHOW, handlePlayListViewEvent);
			controller.removeEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}
	}
}
