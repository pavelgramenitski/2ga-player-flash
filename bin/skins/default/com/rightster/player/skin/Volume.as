package com.rightster.player.skin {
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;

	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.events.VolumeEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.IColors;
	import com.rightster.utils.VolumeUtils;

	import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author KJR
	 */
	public class Volume extends MovieClip {
		private static const VOLUME_BAR_PIXEL_SIZE : Number = 2;
		private static const VOLUME_BAR_XPOS : Number = 19;
		private static const VOLUME_BARS : int = 7;
		private static const BARS_WAVE_AMP : Number = 4;
		private static const BARS_WAVE_LEN : Number = 8;
		private static const FULL_VOLUME : Number = 100;
		private static const ZERO_VOLUME : Number = 0;
		private var controller : IController;
		private var speakerBtn : Sprite;
		private var speakerIcon : DisplayObject;
		private var bg : Sprite;
		private var bars : Array;
		private var isDown : Boolean;
		private var _width : Number = 56;
		private var _height : Number = 31;
		private var colorScheme : IColors;

		public function Volume(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			buttonMode = true;
			visible = false;
			createChildren();
			draw();
			layout();
			setStyle();
			registerEventListeners();
		}

		public function dispose() : void {
			unregisterEventListeners();
			controller = null;
			colorScheme = null;
		}

		public function setAdvertMode(flag : Boolean) : void {
			for (var i : int = 0; i < bars.length; i++) {
				Sprite(bars[i]).visible = !flag;
			}
		}

		override public function set width(h : Number) : void {
			_width = h;
			layout();
		}

		override public function get width() : Number {
			return _width;
		}

		private function speakerOutHandler(event : MouseEvent = null) : void {
			speakerIcon.transform.colorTransform = (controller.isMuted()) ? colorScheme.inactiveCT : colorScheme.primaryCT;
		}

		private function speakerOverHandler(event : MouseEvent = null) : void {
			if (!Skin.isAdvert) {
				speakerIcon.transform.colorTransform = colorScheme.highlightCT;
			} else {
				speakerIcon.transform.colorTransform = colorScheme.advertCT;
			}
		}

		private function stateChangeHandler(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					setSpeaker();
					visible = true;
					break;
			}
		}

		private function muteHandler(e : MouseEvent) : void {
			if (controller.isMuted() || controller.placement.startMuted) {
				controller.unMute();
			} else {
				controller.mute();
			}
			speakerOverHandler();
		}

		private function clickHandler(event : MouseEvent = null) : void {
			if (this.mouseX < (bars[0] as Sprite).x) {
				controller.setVolume(ZERO_VOLUME);
			} else if (this.mouseX > (bars[6] as Sprite).x) {
				controller.setVolume(FULL_VOLUME);
			} else {
				var vol : Number = (this.mouseX - (bars[0] as Sprite).x) / ((bars[6] as Sprite).x - (bars[0] as Sprite).x);
				controller.setVolume(Math.round(VolumeUtils.easeInQuad(vol * FULL_VOLUME)));
			}

			speakerOverHandler();
			setVolumeBarsDisplayHeightAndColour();
		}

		private function mouseDownHandler(evt : MouseEvent) : void {
			addEventListener(MouseEvent.MOUSE_MOVE, moveHandler, false, 0, true);
			isDown = true;
		}

		private function overHandler(e : MouseEvent) : void {
			addEventListener(MouseEvent.MOUSE_MOVE, moveHandler, false, 0, true);
			speakerOverHandler();
		}

		private function outHandler(e : MouseEvent = null) : void {
			removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			for (var i : int = 0; i < VOLUME_BARS; i++) {
				(bars[i] as Sprite).height = 2 + i * 2;
			}
			speakerOutHandler();
			setVolumeBarsDisplayState();
			isDown = false;
		}

		private function moveHandler(event : MouseEvent) : void {
			setVolumeBarsDisplayHeightAndColour();
			if (isDown) {
				clickHandler();
			}
		}

		private function exitFullScreenHandler(e : ResizeEvent) : void {
			outHandler();
		}

		private function setStyle() : void {
			speakerIcon.transform.colorTransform = colorScheme.primaryCT;
			bg.alpha = 0;
			speakerBtn.alpha = 0;
		}

		private function createChildren() : void {
			// background
			bg = new Sprite();
			addChild(bg);

			// the speaker button
			speakerBtn = new Sprite();
			addChild(speakerBtn);

			var Texture : Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.VolumeSpeakerIcon);
			var rect : Rectangle = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.VolumeSpeakerIcon);
			speakerIcon = new Texture();
			speakerIcon.width = rect.width;
			speakerIcon.height = rect.height;

			addChild(speakerIcon);
			speakerIcon.x = 0;

			createVolumeBars();
		}

		private function draw() : void {
			with(bg) {
				graphics.clear();
				graphics.beginFill(0xffcc00, 1);
				graphics.drawRect(0, 0, _width, _height);
				graphics.endFill();
			}

			with(speakerBtn) {
				graphics.clear();
				graphics.beginFill(0xff0000, 1);

				// TODO:scope size correctly
				graphics.drawRect(0, 0, 16, 23);

				graphics.endFill();
			}
		}

		private function createVolumeBars() : void {
			// create volume bars
			bars = [];

			var xpos : Number = VOLUME_BAR_XPOS;
			var ypos : Number = this.height / 2;
			var bar : Sprite;

			for (var i : int = 0; i < VOLUME_BARS; i++) {
				var h : Number = 2 + i * VOLUME_BAR_PIXEL_SIZE;
				bar = renderVolumeBarWithHeight(h);
				bars.push(bar);
				addChild(bar);
				bar.y = ypos;
				bar.x = xpos;
				xpos += VOLUME_BAR_PIXEL_SIZE * 2;
			}
		}

		private function renderVolumeBarWithHeight(h : Number) : Sprite {
			var bar : Sprite = new Sprite();
			bar.mouseEnabled = false;

			var w : Number = VOLUME_BAR_PIXEL_SIZE;
			with(bar) {
				graphics.clear();
				graphics.beginFill(0xff0000, 1);
				graphics.drawRect(0, -(h / 2), w, h);
				graphics.endFill();
			}

			return bar;
		}

		private function layout() : void {
			var centerY : Number = _height / 2;
			bg.x = 0;
			bg.y = 0;
			bg.width = _width;
			bg.height = _height;

			speakerBtn.y = centerY - (speakerBtn.height / 2);
			speakerIcon.y = centerY - (speakerIcon.height / 2);

			for (var i : int = 0; i < bars.length; i++) {
				var bar : Sprite = bars[i] as Sprite;
				bar.y = centerY;
			}
		}

		private function setVolumeBarsDisplayState() : void {
			for (var i : int = 0; i < VOLUME_BARS; i++) {
				if (i < Math.round(VolumeUtils.formatToCodeLevel(VolumeUtils.reverseEiQ(controller.getVolume())) * VOLUME_BARS) && !controller.isMuted()) {
					(bars[i] as Sprite).transform.colorTransform = colorScheme.primaryCT;
				} else {
					(bars[i] as Sprite).transform.colorTransform = colorScheme.inactiveCT;
				}
			}
		}

		private function setVolumeBarsDisplayHeightAndColour() : void {
			var d : Number;
			for (var i : int = 0; i < VOLUME_BARS; i++) {
				d = Math.abs((bars[i] as Sprite).x - mouseX);
				d = d > BARS_WAVE_LEN ? BARS_WAVE_LEN : d;
				(bars[i] as Sprite).height = 2 + i * 2 + ((BARS_WAVE_LEN - d) / BARS_WAVE_LEN) * BARS_WAVE_AMP;

				if (i < Math.round(VolumeUtils.formatToCodeLevel(VolumeUtils.reverseEiQ(controller.getVolume())) * VOLUME_BARS) && !controller.isMuted()) {
					(bars[i] as Sprite).transform.colorTransform = colorScheme.highlightCT;
				}
			}
		}

		private function setSpeaker(e : VolumeEvent = null) : void {
			if (controller.isMuted() || controller.placement.startMuted) {
				speakerIcon.transform.colorTransform = colorScheme.inactiveCT;
			} else {
				speakerIcon.transform.colorTransform = colorScheme.primaryCT;
			}
			setVolumeBarsDisplayState();
		}

		private function registerEventListeners() : void {
			bg.addEventListener(MouseEvent.CLICK, clickHandler);

			speakerBtn.addEventListener(MouseEvent.CLICK, muteHandler);
			speakerBtn.addEventListener(MouseEvent.MOUSE_OVER, speakerOverHandler);
			speakerBtn.addEventListener(MouseEvent.MOUSE_OUT, speakerOutHandler);

			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.MOUSE_UP, outHandler);

			this.controller.stage.addEventListener(MouseEvent.MOUSE_UP, outHandler);

			controller.addEventListener(VolumeEvent.CHANGE, setSpeaker);
			controller.addEventListener(VolumeEvent.MUTE, setSpeaker);
			controller.addEventListener(VolumeEvent.UNMUTE, setSpeaker);
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChangeHandler);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullScreenHandler);
		}

		private function unregisterEventListeners() : void {
			bg.removeEventListener(MouseEvent.CLICK, clickHandler);
			speakerBtn.removeEventListener(MouseEvent.CLICK, muteHandler);
			speakerBtn.removeEventListener(MouseEvent.MOUSE_OVER, speakerOverHandler);
			speakerBtn.removeEventListener(MouseEvent.MOUSE_OUT, speakerOutHandler);

			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			removeEventListener(MouseEvent.MOUSE_UP, outHandler);

			this.controller.stage.removeEventListener(MouseEvent.MOUSE_UP, outHandler);

			controller.removeEventListener(VolumeEvent.CHANGE, setSpeaker);
			controller.removeEventListener(VolumeEvent.MUTE, setSpeaker);
			controller.removeEventListener(VolumeEvent.UNMUTE, setSpeaker);
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChangeHandler);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullScreenHandler);
		}
	}
}
