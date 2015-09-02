package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.IColors;

	import flash.display.BlendMode;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author KJR
	 */
	public class Scrubber extends Sprite {
		private static const BAR_HEIGHT : Number = 8;
		private static const TOOLTIP_BAR_WIDTH : Number = 1;
		private static const TOOLTIP_BAR_HEIGHT : Number = 39;
		private static const UPDATE_RATE : Number = 1000 / 60;
		private static const DRIVER_WIDTH : Number = 0;
		// after quality change skip few updates
		private static const SKIP_UPDATES_AFTER_QUALITY_CHANGE : int = 5;
		private var controller : IController;
		private var _width : Number;
		private var _height : Number = 8;
		private var _chromeHeight : Number = 0;
		private var bgBar : Sprite;
		private var bufferBar : Sprite;
		private var progressBar : Sprite;
		private var toolTip : Tooltip;
		private var toolTipBar : Sprite;
		private var timer : Timer;
		private var progress : Number;
		private var buffer : Number;
		private var dragging : Boolean;
		private var pausedForDragging : Boolean;
		private var skipUpdates : int = 0;
		private var colorScheme : IColors;

		public function Scrubber(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			this.blendMode = BlendMode.LAYER;
			mouseChildren = mouseEnabled = false;
			useHandCursor = buttonMode = true;
			timer = new Timer(UPDATE_RATE, 0);
			createChildren();
			draw();
			layout();
			registerEventListeners();
			startPosition();
			setStyle();
		}

		/*
		 * PUBLIC METHODS
		 */
		public function dispose() : void {
			if (timer.running) {
				timer.stop();
			}

			unregisterEventListeners();

			timer = null;
			controller = null;
		}

		public function updateAdvert(time : Number = 0, duration : Number = 0) : void {
			var progress : Number = time / duration;
			progress = progress > 1 ? 1 : progress;
			updateBarWithWidth(progressBar, progress * (_width));
		}

		public function startPosition() : void {
			updateBarWithWidth(progressBar, 0);
			updateBarWithWidth(bufferBar, 0);
		}

		public function setStyle() : void {
			progressBar.transform.colorTransform = colorScheme.highlightCT;
			bufferBar.transform.colorTransform = colorScheme.inactiveCT;
			bgBar.transform.colorTransform = colorScheme.backgroundCT;
			toolTipBar.transform.colorTransform = colorScheme.primaryCT;
			bufferBar.visible = true;
			toolTip.colorScheme = this.colorScheme;
		}

		public function setStyleAdvert() : void {
			progressBar.transform.colorTransform = colorScheme.advertCT;
			bgBar.transform.colorTransform = colorScheme.backgroundCT;
			bufferBar.visible = false;
		}

		/*
		 * GETTERS/SETTERS
		 */
		override public function set width(n : Number) : void {
			_width = n;
			updateBarWithWidth(bgBar, _width);
			playerStateEventHandler();
		}

		override public function set height(h : Number) : void {
			_height = h;
			layout();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function get width() : Number {
			return _width;
		}

		public function get chromeHeight() : Number {
			return _chromeHeight;
		}

		public function set chromeHeight(value : Number) : void {
			_chromeHeight = value;
			draw();
			layout();
		}

		/*
		 * EVENT HANDLERS
		 */
		private function mediaProviderMetaDataHandler(e : MediaProviderEvent) : void {
			if (controller.getDuration() > 0) {
				mouseChildren = mouseEnabled = true;
			}
		}

		private function playbackQualityChangeHandler(e : PlaybackQualityEvent) : void {
			skipUpdates = SKIP_UPDATES_AFTER_QUALITY_CHANGE;
		}

		private function playerStateEventHandler(e : PlayerStateEvent = null) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					startPosition();
					break;
				case PlayerState.VIDEO_CUED :
					mouseChildren = mouseEnabled = false;
					break;
				case PlayerState.VIDEO_PLAYING :
					timer.start();
					update();
					break;
				case PlayerState.VIDEO_STARTED :
					// handled in onMetaData
					timer.start();
					update();
					break;
				case PlayerState.VIDEO_ENDED :
				case PlayerState.PLAYLIST_ENDED :
					timer.stop();
					endPosition();
					break;
				case PlayerState.AD_STARTED :
					timer.stop();
				default :
			}
		}

		private function update(e : TimerEvent = null) : void {
			progress = controller.getCurrentTime() / controller.getDuration();
			progress = progress > 1 ? 1 : progress;
			buffer = controller.getVideoBytesLoaded() / controller.getVideoBytesTotal();
			buffer = buffer > 1 ? 1 : buffer;

			if (!dragging) {
				if (skipUpdates > 0) {
					skipUpdates--;
				} else {
					updateBarWithWidth(progressBar, progress * (_width - DRIVER_WIDTH));
				}
			}

			updateBarWithWidth(bufferBar, buffer * (_width - DRIVER_WIDTH) + DRIVER_WIDTH);
		}

		private function bgMouseDownHandler(e : MouseEvent) : void {
			if (shouldPreventMouseEvents()) {
				return;
			}

			var ratio : Number = (this.mouseX / _width < 1) ? this.mouseX / _width : 1;
			controller.seekTo(ratio * controller.getDuration(), true);
		}

		private function bgMouseOverMoveHandler(evt : MouseEvent) : void {
			if (shouldPreventMouseEvents()) {
				return;
			}

			toolTipBar.x = this.mouseX + 2.5;

			var ratio : Number = (this.mouseX / _width < 1) ? this.mouseX / _width : 1;
			var duration : Number = Number(Math.round(controller.getDuration()));
			var showHours : Boolean = Math.floor(duration / 3600) > 0 ? true : false;

			var toolTipTextValue : String = formatDigits(ratio * duration, showHours);
			if (ratio < 0) {
				if (showHours) {
					toolTipTextValue = "0:00:00";
				} else {
					toolTipTextValue = "00:00";
				}
			}

			toolTip.setDisplay(toolTipTextValue);
			toolTip.x = toolTipBar.x - (toolTip.width / 2);

			var eventType : String = String(evt.type);
			switch(eventType) {
				case MouseEvent.MOUSE_OVER:
				case MouseEvent.MOUSE_MOVE:
					toolTip.y = - (chromeHeight + toolTip.height);
					toolTip.visible = true;
					toolTipBar.visible = true;
					var maxRight : Number = Number(bgBar.width - toolTip.width);
					if (toolTip.x >= maxRight) {
						toolTip.x = maxRight;
					}
					if (toolTip.x <= 0) {
						toolTip.x = 0;
					}
					break;
				case MouseEvent.MOUSE_OUT:
				default:
					toolTip.visible = false;
					toolTipBar.visible = false;
					break;
			}
		}

		private function performDragHandler(event : MouseEvent) : void {
			if (shouldPreventMouseEvents()) {
				return;
			}
			var posX : Number = this.mouseX < 0 ? 0 : this.mouseX > (_width - DRIVER_WIDTH) ? (_width - DRIVER_WIDTH) : this.mouseX;
			updateBarWithWidth(progressBar, posX);

			if (posX > buffer * _width) {
			} else {
			}
		}

		private function stopDragHandler(e : Event) : void {
			if (shouldPreventMouseEvents()) {
				return;
			}
			if (dragging) {
				controller.stage.removeEventListener(MouseEvent.MOUSE_MOVE, performDragHandler);
				dragging = false;
				if (pausedForDragging) {
					pausedForDragging = false;
					controller.playVideo();
				}
			}
		}

		/*
		 * PRIVATE METHODS
		 */
		private function endPosition() : void {
			updateBarWithWidth(progressBar, _width);
			updateBarWithWidth(bufferBar, _width);
		}

		private function layout() : void {
			bgBar.height = bufferBar.height = progressBar.height = _height;
			toolTip.y = - this.chromeHeight;
		}

		private function formatDigits(seconds : Number, showHours : Boolean) : String {
			var hr : Number = Math.floor(seconds / 3600);
			var min : Number = Math.floor((seconds % 3600) / 60);
			var sec : Number = Math.floor(seconds % 60);
			var res : String = sec < 10 ? (':0' + sec) : (':' + sec);
			if (showHours) {
				res = min < 10 ? (':0' + min + res) : (':' + min + res);
				res = hr + res;
			} else {
				res = min + res;
			}

			return res;
		}

		private function createChildren() : void {
			bgBar = new Sprite();
			addChild(bgBar);

			bufferBar = new Sprite();
			addChild(bufferBar);

			progressBar = new Sprite();
			addChild(progressBar);

			toolTipBar = new Sprite();
			addChild(toolTipBar);
			toolTipBar.y = this.height - TOOLTIP_BAR_HEIGHT;
			toolTipBar.visible = false;

			toolTip = new Tooltip();
			addChild(toolTip);
			toolTip.y = - this.chromeHeight;
			toolTip.visible = false;
		}

		private function draw() : void {
			with (bgBar.graphics) {
				clear();
				beginFill(0xff0000, 1);
				drawRect(0, 0, 0, BAR_HEIGHT);
				endFill();
			}

			with (bufferBar.graphics) {
				clear();
				beginFill(0xff0000, 1);
				drawRect(0, 0, 0, BAR_HEIGHT);
				endFill();
			}

			with (progressBar.graphics) {
				clear();
				beginFill(0xff0000, 1);
				drawRect(0, 0, 0, BAR_HEIGHT);
				endFill();
			}

			with (toolTipBar.graphics) {
				clear();
				beginFill(0xffffff, 1);
				drawRect(0, 0, TOOLTIP_BAR_WIDTH, this.height + this.chromeHeight);
				endFill();
			}
		}

		private function updateBarWithWidth(target : Sprite, w : Number) : void {
			// if not a number do not proceed
			if (isNaN(w)) {
				return;
			}

			with (target.graphics) {
				clear();
				beginFill(0xff0000, 1);
				drawRect(0, 0, w, BAR_HEIGHT);
				endFill();
			}

			target.width = w;
		}

		private function registerEventListeners() : void {
			controller.stage.addEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
			controller.stage.addEventListener(MouseEvent.ROLL_OUT, stopDragHandler);
			controller.stage.addEventListener(Event.MOUSE_LEAVE, stopDragHandler);
			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.addEventListener(PlaybackQualityEvent.CHANGE, playbackQualityChangeHandler);
			controller.addEventListener(MediaProviderEvent.META_DATA, mediaProviderMetaDataHandler);

			addEventListener(MouseEvent.MOUSE_DOWN, bgMouseDownHandler);
			addEventListener(MouseEvent.MOUSE_MOVE, bgMouseOverMoveHandler);
			addEventListener(MouseEvent.MOUSE_OVER, bgMouseOverMoveHandler);
			addEventListener(MouseEvent.MOUSE_OUT, bgMouseOverMoveHandler);

			timer.addEventListener(TimerEvent.TIMER, update);
		}

		private function unregisterEventListeners() : void {
			controller.stage.removeEventListener(MouseEvent.MOUSE_UP, stopDragHandler);
			controller.stage.removeEventListener(MouseEvent.ROLL_OUT, stopDragHandler);
			controller.stage.removeEventListener(Event.MOUSE_LEAVE, stopDragHandler);
			controller.removeEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.removeEventListener(PlaybackQualityEvent.CHANGE, playbackQualityChangeHandler);
			controller.removeEventListener(MediaProviderEvent.META_DATA, mediaProviderMetaDataHandler);

			removeEventListener(MouseEvent.MOUSE_DOWN, bgMouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_MOVE, bgMouseOverMoveHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, bgMouseOverMoveHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, bgMouseOverMoveHandler);

			timer.removeEventListener(TimerEvent.TIMER, update);
		}

		private function shouldPreventMouseEvents() : Boolean {
			var boolValue : Boolean = false;
			switch (controller.playerState) {
				case  PlayerState.AD_PAUSED :
				case  PlayerState.AD_PLAYING:
				case  PlayerState.AD_STARTED:
					boolValue = true;
					break;
				default:
					boolValue = false;
			}

			return boolValue;
		}
	}
}