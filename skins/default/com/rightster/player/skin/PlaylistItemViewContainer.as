package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.model.IPlaylist;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.view.IColors;

	import flash.display.Sprite;

	/**
	 * @author KJR
	 */
	public class PlaylistItemViewContainer extends Sprite {
		private const MIN_ROWS : int = 1;
		private const MIN_COLS : int = 1;
		private var controller : IController;
		private var colorScheme : IColors;
		private var playlistItems : Array;
		private var bg : Sprite;
		private var container : Sprite;
		private var dummyContainer : Sprite;
		private var layoutIsDirty : Boolean = false;
		private var pageCalculator : PlaylistViewPageCalculator;
		private var _maxWidth : Number;
		private var _maxHeight : Number;
		private var _width : Number;
		private var _height : Number;
		private var _padding : Number = 18;
		private var _maxRows : int;
		private var _maxColumns : int;
		private var _numRows : int = 0;
		private var _numColumns : int = 0;
		private var _currentPage : int;
		private var _numPages : int;
		private var _showing : Boolean = false;
		private var _anchorPoints : Object;

		public function PlaylistItemViewContainer(controller : IController) {
			this.controller = controller;
			this.colorScheme = controller.colors;
			pageCalculator = new PlaylistViewPageCalculator();

			playlistItems = [];
			_currentPage = 0;

			createChildren();

			// set a default initial size of 3 col x 2 row
			_width = (PlaylistItem.WIDTH * _numColumns) + (_padding * _numColumns - 1);
			_height = (PlaylistItem.HEIGHT * _numRows) + (_padding * _numRows);

			draw();
		}

		/*
		 * PUBLIC METHODS
		 */
		public function dispose() : void {
			disposePlaylistItems();
			removeAllChildren();
			pageCalculator = null;
			controller = null;
			colorScheme = null;
			playlistItems = null;
		}

		public function show() : void {
			this.visible = _showing = true;
			layout(true);
		}

		public function hide() : void {
			this.visible = _showing = false;
		}

		public function refresh() : void {
			layout();
		}

		public function clear() : void {
			disposePlaylistItems();
			_numColumns = 0;
			_numRows = 0;
		}

		public function previous() : void {
			_currentPage = (_currentPage < 1) ? _numPages - 1 : _currentPage - 1 ;
			clear();
			layout(true);
		}

		public function next() : void {
			_currentPage = (_currentPage == _numPages - 1) ? 0 : _currentPage + 1;
			clear();
			layout(true);
		}

		/*
		 * GETTERS SETTERS 
		 */
		override public function get width() : Number {
			return _width;
		}

		override public function set width(value : Number) : void {
			_width = (_maxWidth && value > _maxWidth) ? _maxWidth : value;
			draw();
			layout();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(value : Number) : void {
			_height = (_maxHeight && value > _maxHeight) ? _maxHeight : value;
			draw();
			layout();
		}

		public function get maxWidth() : Number {
			return _maxWidth;
		}

		public function set maxWidth(value : Number) : void {
			_maxWidth = value;
		}

		public function get maxHeight() : Number {
			return _maxHeight;
		}

		public function set maxHeight(value : Number) : void {
			_maxHeight = value;
		}

		public function get padding() : Number {
			return _padding;
		}

		public function set padding(value : Number) : void {
			_padding = value;
			draw();
			layout();
		}

		public function get maxRows() : int {
			return _maxRows;
		}

		public function set maxRows(value : int) : void {
			_maxRows = value;
		}

		public function get maxColumns() : int {
			return _maxColumns;
		}

		public function set maxColumns(value : int) : void {
			_maxColumns = value;
		}

		public function get numRows() : int {
			return _numRows;
		}

		public function get numColumns() : int {
			return _numColumns;
		}

		public function get numPages() : int {
			return _numPages;
		}

		public function get numItems() : int {
			return playlistItems.length || 0;
		}

		public function get currentPage() : int {
			return _currentPage;
		}

		public function get anchorPoints() : Object {
			return _anchorPoints;
		}

		public function get innerWidth() : Number {
			return container.width;
		}

		/*
		 * EVENT HANDLERS 
		 */
		/*
		 * PRIVATE METHODS
		 */
		private function createChildren() : void {
			bg = new Sprite();
			addChild(bg);

			dummyContainer = new Sprite();
			addChild(dummyContainer);

			container = new Sprite();
			addChild(container);
		}

		private function removeAllChildren() : void {
			removeChildren(0, numChildren - 1);
		}

		private function draw() : void {
			with(bg.graphics) {
				clear();
				beginFill(0xff0000, 0);
				drawRect(0, 0, _width, _height);
				endFill();
			}
		}

		private function layout(forced : Boolean = false) : void {
			if (_showing && !layoutIsDirty) {
				var rows : int = calculateRows();
				var cols : int = calculateColumns();

				var changed : Boolean = ( (rows == _numRows) && (cols == _numColumns) ) ? false : true;

				// if not invoked by previous or next...
				if (!forced) {
					var previousPage : int = _currentPage;
					// calculate which page to display based on the current video being shown
					var matrix : int = _numRows * _numColumns;
					var index : int = controller.getPlaylistIndex();
					var proposed : int = pageCalculator.calculateIndex(index, matrix);

					if (proposed != previousPage) {
						_currentPage = proposed;
						changed = true;
					}
				}

				if (changed || forced) {
					// set and calculate
					_numRows = rows;
					_numColumns = cols;
					_numPages = calculateNumPages();

					disposePlaylistItems();

					var success : Boolean = createPlaylistItemsForPageIndex(_currentPage);

					if (!success) {
						if (_currentPage == 0) {
							layoutIsDirty = true;
						} else {
							previous();
						}
					}

					layoutPlaylistItems();
					populatePlaylistItemsWithPageIndex(_currentPage);
				}
			}

			centerAlign(container);
			calculateAnchorPoints();

			// clear flag
			layoutIsDirty = false;
		}

		private function calculateColumns() : int {
			var value : int;
			var availableWidth : Number = this.width;
			var count : int = 1;
			var proposedWidth : Number = PlaylistItem.WIDTH;

			while (proposedWidth <= availableWidth) {
				++count;
				proposedWidth = (count * PlaylistItem.WIDTH) + ((count - 1) * _padding);
			}

			value = (count - 1 >= MIN_COLS) ? count - 1 : MIN_COLS;

			return value;
		}

		private function calculateRows() : int {
			var value : int;
			var availableHeight : Number = this.height;
			var count : int = 1;
			var proposedHeight : Number = PlaylistItem.HEIGHT;

			while (proposedHeight <= availableHeight) {
				++count;
				proposedHeight = (count * PlaylistItem.HEIGHT) + ((count - 1) * _padding) ;
			}

			value = (count - 1 >= MIN_ROWS) ? count - 1 : MIN_ROWS;

			return value;
		}

		private function calculateNumPages() : int {
			var playlist : IPlaylist = this.controller.getPlaylist();
			var len : int = playlist.length;
			var matrix : int = this.numColumns * this.numRows;

			return Math.ceil(len / matrix);
		}

		private function createPlaylistItemsForPageIndex(value : int = 0) : Boolean {
			var playlist : IPlaylist = this.controller.getPlaylist();
			var matrix : int = this.numColumns * this.numRows;
			var offset : int = matrix * value;
			var len : int = playlist.length - offset;
			var total : int = (len < matrix) ? len : matrix;

			// nothing to layout - repagination required
			if (total < 1) {
				return false;
			}

			for (var i : int = 0; i < total; i++) {
				var playlistItem : PlaylistItem = new PlaylistItem(this.controller);
				playlistItems.push(playlistItem);
				container.addChild(playlistItem);
			}

			return true;
		}

		private function layoutPlaylistItems() : void {
			var xPos : int = 0;
			var yPos : int = 0;
			var len : int = playlistItems.length;

			for (var i : int = 1; i <= len; i++) {
				var playlistItem : PlaylistItem = playlistItems[i - 1] as PlaylistItem;

				if ( i > 1 ) {
					xPos += PlaylistItem.WIDTH + padding;
				}

				// new row
				if ((i > this.numColumns) && (( i - 1) % (this.numColumns) == 0)) {
					xPos = 0;
					yPos += PlaylistItem.HEIGHT + padding;
				}

				playlistItem.x = xPos;
				playlistItem.y = yPos;
			}
		}

		private function populatePlaylistItemsWithPageIndex(value : int) : void {
			var playlist : IPlaylist = this.controller.getPlaylist();
			var matrix : int = this.numColumns * this.numRows;
			var offset : int = matrix * value;
			var len : int = playlist.length - offset;
			var total : int = (len < matrix) ? len : matrix;

			for (var i : int = 0; i < total; i++) {
				var playlistItem : PlaylistItem = playlistItems[i] as PlaylistItem;
				var metaVideo : MetaVideo = playlist.getItemAt(i + offset);

				playlistItem.load(metaVideo);
			}
		}

		private function disposePlaylistItems() : void {
			for (var i : int = this.playlistItems.length - 1; i >= 0; i--) {
				var playlistItem : PlaylistItem = this.playlistItems[i] as PlaylistItem;
				playlistItem.dispose();
				container.removeChild(playlistItem);
				playlistItems.pop();
			}
		}

		private function centerAlign(target : Sprite) : void {
			target.x = (this.width / 2) - (target.width / 2);
		}

		private function calculateAnchorPoints() : void {
			var factor : int = (_numRows - 1 < 0) ? 0 : _numRows - 1;
			var intendedWidth : Number = (PlaylistItem.WIDTH * _numColumns) + (_padding * (_numColumns - 1));
			var intendedHeight : Number = container.height;

			with(dummyContainer.graphics) {
				clear();
				beginFill(0x00ffff, 0);
				drawRect(0, 0, intendedWidth, intendedHeight);
				endFill();
			}

			centerAlign(dummyContainer);

			_anchorPoints = _anchorPoints || {};
			_anchorPoints.left = dummyContainer.x;
			_anchorPoints.right = dummyContainer.x + dummyContainer.width;
			_anchorPoints.top = container.y;
			_anchorPoints.bottom = container.y + (_numRows * PlaylistItem.HEIGHT) + (_numRows * _padding);
			_anchorPoints.middle = container.y + ((_numRows * PlaylistItem.HEIGHT) + (factor * _padding)) / 2;

			// anchor left
			container.x = _anchorPoints.left;
		}
	}
}
