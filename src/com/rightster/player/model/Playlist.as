package com.rightster.player.model {
	import com.rightster.player.controller.IController;
	import com.rightster.utils.ArrayUtils;

	/**
	 * @author Arun
	 */
	public class Playlist implements IPlaylist {
		private var restorePlaylist : Array;
		private var restoreSet : Boolean = false;
		private var list : Array;
		private var index : Number;
		private var _loopMode : String = LoopMode.NONE;
		private var controller : IController;

		public function Playlist(controller : IController) : void {
			list = [];
			index = 0;
			this.controller = controller;
		}
		
		public function resetPlaylist():void{
			list = [];
		}

		public function getItemAt(idx : Number = -1) : MetaVideo {
			try {
				return list[idx];
			} catch(e : Error) {
			}
			return null;
		}

		public function insertItem(itm : MetaVideo, idx : Number = -1) : void {
			if (idx >= 0 && idx < list.length) {
				list.splice(idx, 0, itm);
			} else {
				list.push(itm);
			}
		}

		public function removeItemAt(idx : Number) : void {
			if (idx >= 0 && idx < list.length && list.length > 0) {
				list.splice(idx, 1);
			}
		}

		public function contains(item : MetaVideo) : Boolean {
			for (var i : Number = 0; i < length; i++) {
				if (getItemAt(i) == item) return true;
			}
			return false;
		}

		public function getList() : Array {
			return list;
		}

		public function randomize() : void {
			var copy : Array = list.slice();
			setRestorePlaylist(copy);
			var random : Array = list.slice();
			list = ArrayUtils.randomize(random);
			for (var i : int = 0; i < list.length; i++) {
				var video : MetaVideo = list[i] as MetaVideo;
				video.playlistIndex = i;
			}
		}

		public function restore() : void {
			var restore : Array = getRestorePlaylist();
			if (restore) {
				list = restore;
			}
		}

		public function get currentIndex() : Number {
			return index;
		}

		public function get currentItem() : MetaVideo {
			return index >= 0 ? getItemAt(index) : null;
		}

		public function get length() : Number {
			return list.length;
		}

		public function set currentIndex(idx : Number) : void {
			if (idx >= 0) {
				index = idx;
			} else {
				index = -1;
			}
		}

		public function get stream() : MetaStream {
			return video == null ? null : video.metaStreams[controller.getPlaybackQuality()] as MetaStream;
		}

		public function get loopMode() : String {
			return _loopMode;
		}

		public function set loopMode(value : String) : void {
			_loopMode = value;
		}

		public function nextVideo() : void {
			if (length > 1) {
				var next : uint = isLastVideo() ? 0 : currentIndex + 1;
				controller.playVideoAt(next);
			} else if (controller.playerState != PlayerState.PLAYER_ERROR) {
				controller.playVideoAt(currentIndex);
			}
		}

		public function previousVideo() : void {
			if (length > 1) {
				var prev : uint = currentIndex == 0 ? (length - 1) : currentIndex - 1;
				controller.playVideoAt(prev);
			} else if (controller.playerState != PlayerState.PLAYER_ERROR) {
				controller.playVideoAt(currentIndex);
			}
		}

		public function get playlistIndex() : uint {
			return currentIndex;
		}

		public function get video() : MetaVideo {
			return getItemAt(currentIndex);
		}

		public function get playlist() : Array {
			return list;
		}

		public function isLastVideo() : Boolean {
			return (currentIndex == (length - 1)) ? true : false;
		}

		private function getRestorePlaylist() : Array {
			if (restoreSet) {
				restoreSet = false;
				return restorePlaylist;
			}

			return null;
		}

		private function setRestorePlaylist(arr : Array) : void {
			if (!restoreSet) {
				restoreSet = true;
				restorePlaylist = arr;

				for (var i : int = 0; i < restorePlaylist.length; i++) {
					var video : MetaVideo = restorePlaylist[i] as MetaVideo;
					video.playlistIndex = i;
				}
			}
		}
	}
}