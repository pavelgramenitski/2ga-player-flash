package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;

	/**
	 * @author KJR
	 */
	public class PlaylistView extends Sprite {
		private const DEFAULT_HEIGHT : Number = 262;
		private const STANDARD_PADDING_TOP : Number = 22;
		private const MINIMIZED_PADDING_OFFSET : Number = -10;
		private const PADDING : Number = 83;
		private const PADDING_ICONS : Number = 12;
		private const TITLE_MARGIN_RIGHT : Number = 10;
		private const ITEM_VIEW_CONTAINER_Y : Number = 52;
		private const MARGIN_LEFT_PLAY_ALL : Number = 242;
		// private const PLAY_ALL_PADDING_LEFT : Number = 36;
		private var controller : IController;
		private var colorScheme : IColors;
		private var blocker : Sprite;
		private var bg : Sprite;
		private var tf : TextField;
		private var btnClose : CloseButton;
		private var btnPlayAll : PlayAllButton;
		private var previousIcon : DisplayObject;
		private var nextIcon : DisplayObject;
		private var previous : Sprite;
		private var next : Sprite;
		private var didPauseVideo : Boolean;
		private var _width : Number;
		private var _height : Number;
		private var _explicitMinWidth : Number = 300;
		private var _explicitMinHeight : Number = 145;
		private var _showing : Boolean;
		private var _marginBottom : Number = 87;
		private var _paddingTop : Number;
		private var _viewContainerTop : Number;
		private var playlistItemViewContainer : PlaylistItemViewContainer;
		private var strTitle : String = "";

		public function PlaylistView(controller : IController) {
			this.controller = controller;
			this.colorScheme = controller.colors;

			_width = DEFAULT_HEIGHT;
			_height = DEFAULT_HEIGHT;

			createChildren();
			assertIndices();
			setInitialDisplayState();
			registerEventListeners();

			draw();
			layout();
		}

		/*
		 * PUBLIC METHODS
		 */
		public function dispose() : void {
			// unregister
			unregisterEventListeners();

			// dispose
			btnPlayAll.dispose();
			btnClose.dispose();
			playlistItemViewContainer.dispose();

			// remove
			removeAllChildren();

			// nullify
			btnPlayAll = null;
			btnClose = null;
			playlistItemViewContainer = null;
			colorScheme = null;
			controller = null;
		}

		public function show() : void {
			resizeHandler();
			this.playlistItemViewContainer.show();
			layout();
			this.visible = _showing = true;
		}

		public function hide() : void {
			this.visible = _showing = false;
			this.playlistItemViewContainer.hide();
			this.playlistItemViewContainer.clear();
		}

		/*
		 * GETTERS / SETTERS
		 * 
		 */
		override public function get width() : Number {
			return _width;
		}

		override public function set width(value : Number) : void {
			_width = ( _explicitMinWidth && value > _explicitMinWidth ) ? value : _explicitMinWidth;
			draw();
			layout();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(value : Number) : void {
			_height = ( _explicitMinHeight && value > _explicitMinHeight ) ? value : _explicitMinHeight;
			draw();
			layout();
		}

		public function get explicitMinWidth() : Number {
			return _explicitMinWidth;
		}

		public function get explicitMinHeight() : Number {
			return _explicitMinHeight;
		}

		public function get showing() : Boolean {
			return _showing;
		}

		public function get marginBottom() : Number {
			return _marginBottom;
		}

		public function set marginBottom(value : Number) : void {
			_marginBottom = value;
			resizeHandler();
			draw();
			layout();
		}

		private function get paddingTop() : Number {
			_paddingTop = ((playlistItemViewContainer.numColumns == 1) && (playlistItemViewContainer.numRows == 1)) ? STANDARD_PADDING_TOP + MINIMIZED_PADDING_OFFSET : STANDARD_PADDING_TOP;
			return _paddingTop;
		}

		private function get viewContainerTop() : Number {
			_viewContainerTop = ((playlistItemViewContainer.numColumns == 1) && (playlistItemViewContainer.numRows == 1)) ? ITEM_VIEW_CONTAINER_Y + MINIMIZED_PADDING_OFFSET : ITEM_VIEW_CONTAINER_Y;
			return _viewContainerTop;
		}

		/*
		 * EVENT HANDLERS 
		 */
		private function resizeHandler(event : Event = null) : void {
			this.width = controller.width;
			this.height = controller.height - this.y - this.marginBottom;
		}

		private function navigateMouseOverHandler(e : MouseEvent) : void {
			var icon : DisplayObject = (e.target == previous) ? previousIcon : nextIcon;
			icon.transform.colorTransform = colorScheme.highlightCT;
		}

		private function navigateMouseOutHandler(e : MouseEvent) : void {
			var icon : DisplayObject = (e.target == previous) ? previousIcon : nextIcon;
			icon.transform.colorTransform = colorScheme.primaryCT;
		}

		private function navigateClickHandler(e : MouseEvent) : void {
			e.target == previous ? playlistItemViewContainer.previous() : playlistItemViewContainer.next();
			repositionChildren();
		}

		private function closeClickHandler(e : MouseEvent) : void {
			controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.HIDE));

			if (didPauseVideo) {
				controller.playVideo();
				didPauseVideo = false;
			}
		}

		private function playlistViewHandler(event : PlaylistViewEvent) : void {
			switch (controller.playerState) {
				case PlayerState.AD_PLAYING :
				case PlayerState.VIDEO_PLAYING :
				case PlayerState.PLAYER_BUFFERING :
					controller.pauseVideo();
					didPauseVideo = true;
					break;
			}
		}

		private function pluginRefreshHandler(event : PluginEvent) : void {
			this.hide();
		}

		/*
		 * PRIVATE METHODS
		 */
		private function createChildren() : void {
			var Texture : Class;
			var rect : Rectangle;

			blocker = new Sprite();
			addChild(blocker);

			bg = new Sprite();
			addChild(bg);

			playlistItemViewContainer = new PlaylistItemViewContainer(controller);
			addChild(playlistItemViewContainer);
			playlistItemViewContainer.width = _width - (PADDING * 2);
			playlistItemViewContainer.height = _height - paddingTop;

			// previous icon
			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlaylistNavigationIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlaylistNavigationIcon);
			previousIcon = new Texture();
			previousIcon.width = rect.width;
			previousIcon.height = rect.height;
			addChild(previousIcon);

			// next icon
			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlaylistNavigationIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlaylistNavigationIcon);
			nextIcon = new Texture();
			nextIcon.width = rect.width;
			nextIcon.height = rect.height;
			addChild(nextIcon);
			nextIcon.scaleX = -1;

			// previous button
			previous = new Sprite();
			addChild(previous);

			// next button
			next = new Sprite();
			addChild(next);

			// title
			createTextField();

			// play all button
			btnPlayAll = new PlayAllButton(controller);
			addChild(btnPlayAll);

			// close button
			btnClose = new CloseButton(controller);
			addChild(btnClose);
		}

		private function createTextField() : void {
			var tFormat : TextFormat = new TextFormat();
			tFormat.font = Constants.FONT_NAME;
			tFormat.size = Constants.FONT_SIZE_LARGEST;
			tFormat.leading = 0;
			tf = new TextField();
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.embedFonts = false;
			tf.multiline = false;
			tf.selectable = false;
			tf.defaultTextFormat = tFormat;
			tf.transform.colorTransform = colorScheme.primaryCT;

			addChild(tf);
		}

		private function removeAllChildren() : void {
			removeChildren(0, numChildren - 1);
		}

		private function setInitialDisplayState() : void {
			blocker.buttonMode = true;
			blocker.useHandCursor = false;

			bg.transform.colorTransform = colorScheme.overlayCT;
			bg.alpha = colorScheme.overlayAlpha;

			previousIcon.transform.colorTransform = colorScheme.primaryCT;
			nextIcon.transform.colorTransform = colorScheme.primaryCT;

			previous.buttonMode = true;
			previous.useHandCursor = true;
			next.buttonMode = true;
			next.useHandCursor = true;

			setTitle(controller.placement.playListTitle);
		}

		private function assertIndices() : void {
			var index : int = 0;
			setChildIndex(blocker, index);
			setChildIndex(bg, ++index);
			setChildIndex(playlistItemViewContainer, ++index);

			setChildIndex(previous, ++index);
			setChildIndex(next, ++index);

			setChildIndex(previousIcon, ++index);
			setChildIndex(nextIcon, ++index);

			setChildIndex(tf, ++index);
			setChildIndex(btnPlayAll, ++index);
		}

		private function draw() : void {
			// TODO: fix initial draw fails to scope the explicit height correctly since anchors.bottom. appears to be zero until a resize event occurs post render
			var anchors : Object = playlistItemViewContainer.anchorPoints;
			var explicitHeight : Number = (anchors.bottom > 0) ? playlistItemViewContainer.y + anchors.bottom : _height;

			with(blocker.graphics) {
				clear();
				beginFill(0xff0000, 0);
				drawRect(0, 0, _width, this.controller.height - this.y);
				endFill();
			}

			with(bg.graphics) {
				clear();
				beginFill(0xff0000, 1);
				drawRect(0, 0, _width, explicitHeight);
				endFill();
			}

			with(previous.graphics) {
				clear();
				beginFill(0xff0000, 0);
				drawRect(0, 0, PADDING, explicitHeight);
				endFill();
			}

			// next
			with(next.graphics) {
				clear();
				beginFill(0xff0000, 0);

				drawRect(0, 0, PADDING, explicitHeight);
				endFill();
			}
		}

		private function layout() : void {
			playlistItemViewContainer.x = PADDING;
			playlistItemViewContainer.y = ITEM_VIEW_CONTAINER_Y;
			playlistItemViewContainer.width = _width - (PADDING * 2);
			playlistItemViewContainer.height = _height - playlistItemViewContainer.y;
			playlistItemViewContainer.refresh();

			// re-adjust
			playlistItemViewContainer.y = this.viewContainerTop;

			repositionChildren();
		}

		private function repositionChildren() : void {
			var anchors : Object = playlistItemViewContainer.anchorPoints;

			// previous and next hit area buttons
			previous.width = anchors.left + playlistItemViewContainer.x;
			next.x = anchors.right + playlistItemViewContainer.x;
			next.width = this.width - next.width;

			// navigation icons
			previousIcon.y = nextIcon.y = playlistItemViewContainer.y + anchors.middle - previousIcon.height / 2;
			previousIcon.x = previous.width - PADDING_ICONS - previousIcon.width;
			// NOTE: nextIcon is at scaleX = -1!
			nextIcon.x = next.x + PADDING_ICONS + nextIcon.width;

			// availability of navigation
			playlistItemViewContainer.numPages > 1 ? showNavigation(true) : showNavigation(false);

			// title
			tf.x = anchors.left + playlistItemViewContainer.x;
			tf.y = paddingTop;
			tf.visible = playlistItemViewContainer.numColumns > 1 ? true : false;

			// play all
			btnPlayAll.x = tf.x + MARGIN_LEFT_PLAY_ALL;
			// btnPlayAll.x = tf.x + tf.width + PLAY_ALL_PADDING_LEFT;

			// text
			// assertTextFieldMaxWidth();

			btnPlayAll.y = paddingTop;
			btnPlayAll.visible = shouldDisplayPlayAllButton();

			// close button
			btnClose.x = next.x - btnClose.width;
			btnClose.y = paddingTop;

			// text
			assertTextFieldMaxWidth();
		}

		private function assertTextFieldMaxWidth() : void {
			var referenceAsset : DisplayObject = btnPlayAll.visible ? btnPlayAll : btnClose;
			var maxWidth : Number = referenceAsset.x - TITLE_MARGIN_RIGHT - tf.x;

			tf.text = strTitle;

			if (tf.textWidth > maxWidth) {
				var avg : Number = Number(tf.textWidth / tf.length);
				var finalAvg : Number = Number(maxWidth / avg);
				tf.text = strTitle.substring(0, finalAvg - 3) + Constants.ELLIPSIS;
			}

			tf.autoSize = TextFieldAutoSize.LEFT;
		}

		private function setTitle(value : String) : void {
			strTitle = value;
			tf.text = value;
		}

		private function showNavigation(value : Boolean) : void {
			previousIcon.visible = previous.visible = nextIcon.visible = next.visible = value;
		}

		private function shouldDisplayPlayAllButton() : Boolean {
			var shouldDisplay : Boolean = true;

			if (playlistItemViewContainer.numColumns < 3 ) {
				shouldDisplay = false;
			} else if (playlistItemViewContainer.numItems < 3) {
				// shouldDisplay = false;
			}

			return shouldDisplay;
		}

		private function registerEventListeners() : void {
			controller.addEventListener(PluginEvent.REFRESH, pluginRefreshHandler);
			controller.addEventListener(ResizeEvent.RESIZE, resizeHandler);
			controller.addEventListener(PlaylistViewEvent.SHOW, playlistViewHandler);
			btnClose.addEventListener(MouseEvent.CLICK, closeClickHandler);
			previous.addEventListener(MouseEvent.MOUSE_OVER, navigateMouseOverHandler);
			previous.addEventListener(MouseEvent.MOUSE_OUT, navigateMouseOutHandler);
			previous.addEventListener(MouseEvent.CLICK, navigateClickHandler);
			next.addEventListener(MouseEvent.MOUSE_OVER, navigateMouseOverHandler);
			next.addEventListener(MouseEvent.MOUSE_OUT, navigateMouseOutHandler);
			next.addEventListener(MouseEvent.CLICK, navigateClickHandler);
		}

		private function unregisterEventListeners() : void {
			controller.removeEventListener(PluginEvent.REFRESH, pluginRefreshHandler);
			controller.removeEventListener(ResizeEvent.RESIZE, resizeHandler);
			controller.removeEventListener(PlaylistViewEvent.SHOW, playlistViewHandler);
			btnClose.removeEventListener(MouseEvent.CLICK, closeClickHandler);
			previous.removeEventListener(MouseEvent.MOUSE_OVER, navigateMouseOverHandler);
			previous.removeEventListener(MouseEvent.MOUSE_OUT, navigateMouseOutHandler);
			previous.removeEventListener(MouseEvent.CLICK, navigateClickHandler);
			next.removeEventListener(MouseEvent.MOUSE_OVER, navigateMouseOverHandler);
			next.removeEventListener(MouseEvent.MOUSE_OUT, navigateMouseOutHandler);
			next.removeEventListener(MouseEvent.CLICK, navigateClickHandler);
		}
	}
}
