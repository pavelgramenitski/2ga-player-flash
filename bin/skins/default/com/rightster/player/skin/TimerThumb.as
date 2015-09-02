package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.view.IColors;
	import com.rightster.utils.Log;

	// import flash.display.Bitmap;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.utils.Timer;

	/**
	 * @author Ravi Thapa
	 */
	public class TimerThumb extends MovieClip {
		private static var WIDTH : Number = 212;
		private static const HEIGHT : Number = 60;
		// private static const THUMB_WIDTH : Number = 100;
		// private static const THUMB_HEIGHT : Number = 58;
		private static const PADDING_HEIGHT : Number = 2;
		// private static const FADE_IN_TIME : Number = 0.2;
		private static const TXT_SKIP_ASSETS : String = "txt_skip";
		private static const BTN_SKIP_ASSETS : String = "btn_skip";
		private static const TXT_SKIP : String = "Skip Ad";
		private var controller : IController;
		private var colorScheme : IColors;
		private var metaVideo : MetaVideo;
		private var bgSprite : Sprite;
		private var thumbHolder : Sprite;
		// private var thumbImage : Bitmap;
		private var txtSkip : TextField;
		private var skipButton : MovieClip;
		private var request : URLRequest;
		private var timer : Timer;
		private var delay : Number = 1000;

		override public function get width() : Number {
			return WIDTH;
		}

		public function TimerThumb(controller : IController, metaVideo : MetaVideo) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			this.metaVideo = metaVideo;

			txtSkip = this[TXT_SKIP_ASSETS];
			skipButton = this[BTN_SKIP_ASSETS];
			skipButton.visible = false;
			skipButton.buttonMode = true;

			graphics.beginFill(colorScheme.backgroundColor);
			graphics.drawRect(0, 0, WIDTH, HEIGHT);
			graphics.endFill();

			bgSprite = new Sprite();
			bgSprite.graphics.beginFill(colorScheme.baseColor);
			bgSprite.graphics.drawRect(0, 0, WIDTH, HEIGHT - PADDING_HEIGHT);
			bgSprite.graphics.endFill();

			thumbHolder = new Sprite();

			addChild(bgSprite);
			thumbHolder.x = thumbHolder.y = bgSprite.x = bgSprite.y = PADDING_HEIGHT / 2;
			addChild(thumbHolder);
			load();

			timer = new Timer(delay, metaVideo.skipAdDuration);
			timer.addEventListener(TimerEvent.TIMER, timerCompleteFunc);
			timer.addEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteFunc);

			setChildIndex(txtSkip, numChildren - 1);
			setChildIndex(skipButton, numChildren - 1);

			skipButton.addEventListener(MouseEvent.CLICK, mouseEvtFunc);
			skipButton.addEventListener(MouseEvent.MOUSE_OVER, mouseEvtFunc);
			skipButton.addEventListener(MouseEvent.MOUSE_OUT, mouseEvtFunc);

			setStyle();
		}

		private function timerCompleteFunc(evt : TimerEvent) : void {
			switch(String(evt.type)) {
				case TimerEvent.TIMER:
					skipButton.visible = false;
					var skipTime : Number = metaVideo.skipAdDuration - timer.currentCount;
					txtSkip.text = TXT_SKIP + " in " + skipTime;
					break;
				case TimerEvent.TIMER_COMPLETE:
					skipButton.visible = true;
					txtSkip.text = TXT_SKIP;
					break;
			}
			txtSkip.autoSize = TextFieldAutoSize.LEFT;
			txtSkip.width = txtSkip.textWidth;

			skipButton.x = txtSkip.x + txtSkip.width + 5;
		}

		private function mouseEvtFunc(evt : MouseEvent) : void {
			switch(String(evt.type)) {
				case MouseEvent.CLICK:
					skipButton.transform.colorTransform = colorScheme.selectedCT;
					controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_STOP));
					break;
				case MouseEvent.MOUSE_OVER:
					skipButton.transform.colorTransform = colorScheme.highlightCT;
					break;
				case MouseEvent.MOUSE_OUT:
					skipButton.transform.colorTransform = colorScheme.primaryCT;
					break;
			}
		}

		/*
		private function complete(img : Bitmap) : void {
		thumbImage = img;
		thumbImage.width = THUMB_WIDTH;
		thumbImage.height = THUMB_HEIGHT;
		thumbHolder.addChild(thumbImage);
		thumbHolder.alpha = 0;
		GTweener.to(thumbHolder, FADE_IN_TIME, {alpha:1});
		}

		private function errorHandler() : void {
		Log.write("TimerThumb.errorHandler * Count Down Thumb timer load Error");
		}
		 */
		private function setStyle() : void {
			skipButton.transform.colorTransform = colorScheme.primaryCT;
		}

		public function pauseResumeTimer(flag : Boolean) : void {
			if (flag) {
				timer.stop();
			} else {
				if (!timer.running && !skipButton.visible) timer.start();
			}
		}

		public function validateDuration(duration : Number) : void {
			if (duration <= metaVideo.skipAdDuration) {
				visible = false;
				timer.reset();
				timer.stop();
			}
		}

		public function startedAdv() : void {
			if (metaVideo.isSkipAds) {
				timer.reset();
				timer.start();
			} else {
				visible = false;
			}
		}

		public function load() : void {
			if (metaVideo != null) {
				request = new URLRequest(metaVideo.startImageUrl);
				Log.write(request.url, Log.NET);

				// var checkPolicy : Boolean = controller.live;
				// controller.loader.load(request, AssetLoader.TYPE_IMG, new LoaderContext(checkPolicy), false, ErrorCode.ASSET_LOADING_ERROR, "TimerThumb.load * ", complete, errorHandler);
			}
		}

		public function dispose() : void {
			timer.removeEventListener(TimerEvent.TIMER, timerCompleteFunc);
			timer.removeEventListener(TimerEvent.TIMER_COMPLETE, timerCompleteFunc);

			skipButton.removeEventListener(MouseEvent.CLICK, mouseEvtFunc);
			skipButton.removeEventListener(MouseEvent.MOUSE_OVER, mouseEvtFunc);
			skipButton.removeEventListener(MouseEvent.MOUSE_OUT, mouseEvtFunc);

			colorScheme = null;
			controller = null;
		}
	}
}
