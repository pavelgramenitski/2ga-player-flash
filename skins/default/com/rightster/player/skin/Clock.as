package com.rightster.player.skin {
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.IColors;
	//import com.rightster.utils.Log;
	import com.rightster.utils.TimeUtils;

	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;
	import flash.utils.Timer;

	/**
	 * @author KJR
	 */
	public class Clock extends Sprite {
		private const TEXTFIELD_HEIGHT : Number = 16;
		private static const SYMBOL : String = ' / ';
		private static const UPDATE_RATE : Number = 1000;
		private static const LIVE : String = "Live";
		private var controller : IController;
		private var tf : TextField;
		private var tFormat : TextFormat;
		private var timer : Timer;
		private var colorScheme : IColors;
		private var _height : int = 31;
		private var paddingLeft : int = 16;

		public function Clock(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			timer = new Timer(UPDATE_RATE, 0);

			createChildren();
			layout();
			update();
			registerEventListeners();
		}

		public function updateTextDisplay(str : String) : void {
			//Log.write("Clock::updateTextDisplay * value: " + str) ;
			tf.text = str;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.width = Number(tf.textWidth + 5);
		}

		public function dispose() : void {
			if (timer.running) {
				timer.stop();
			}

			unregisterEventListeners();

			tf.text = "";
			colorScheme = null;
			tf = null;
			timer = null;
			controller = null;
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(value : Number) : void {
			_height = value;
			layout();
		}

		private function playerStateHandler(e : PlayerStateEvent) : void {
			//Log.write("Clock::playerStateHandler *state" + controller.playerState);
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					update();
					break;
				case PlayerState.VIDEO_STARTED :
					timer.start();
					update();
					break;
				case PlayerState.VIDEO_PLAYING :
					if (timer && !timer.running) {
						timer.start();
						update();
					}
					break;
				case PlayerState.VIDEO_ENDED :
					if (timer && timer.running) {
						timer.stop();
					}
					// avoid discrepancy between current and duration times
					updateVideoEnd();
					break;
				case PlayerState.AD_STARTED :
					if (timer && timer.running) {
						timer.stop();
					}
					break;
			}
		}

		private function handlePluginRefreshEvent(event : PluginEvent) : void {
			resetTimer();
		}

		private function resetTimer() : void {
			if (timer) {
				if (timer.running) {
					timer.stop();
				}
			}
		}

		private function createChildren() : void {
			tFormat = new TextFormat();
			tFormat.font = Constants.FONT_NAME;
			tFormat.size = Constants.FONT_SIZE_NORMAL;
			tFormat.color = colorScheme.primaryColor;
			tFormat.align = TextFormatAlign.LEFT;
			tFormat.leading = 0;
			tf = new TextField();
			tf.defaultTextFormat = tFormat;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.embedFonts = false;
			tf.selectable = false;
			tf.height = TEXTFIELD_HEIGHT;
			tf.autoSize = TextFieldAutoSize.LEFT;
			tf.text = "";

			addChild(tf);
		}

		private function registerEventListeners() : void {
			timer.addEventListener(TimerEvent.TIMER, update);
			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateHandler);
			controller.addEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}

		private function unregisterEventListeners() : void {
			timer.removeEventListener(TimerEvent.TIMER, update);
			controller.removeEventListener(PlayerStateEvent.CHANGE, playerStateHandler);
			controller.removeEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}

		private function layout() : void {
			tf.x = paddingLeft;
			tf.y = Math.round((_height - tf.height) / 2);
		}

		private function update(e : TimerEvent = null) : void {
			var current : Number = Math.ceil(controller.getCurrentTime());
			var duration : Number = Math.round(controller.getDuration());

			// use if no duration yet available from media provider
			if (duration == 0 && controller.video.duration) {
				duration = controller.video.duration;
			}
			var showHours : Boolean = Math.floor(duration / 3600) > 0 ? true : false;

			var updateString : String = TimeUtils.formatSeconds(current, showHours);
			var beginIndex : uint = updateString.length;

			updateString += (!controller.video.isLive) ? (" " + SYMBOL + " " + TimeUtils.formatSeconds(duration, showHours)) : (" " + SYMBOL + " " + LIVE);

			tFormat.color = colorScheme.clockInactiveColor;
			updateClock(updateString, tFormat, beginIndex);
		}

		private function updateVideoEnd() : void {
			var duration : Number = Math.round(controller.getDuration());

			// use if no duration yet available from media provider
			if (duration == 0 && controller.video.duration) {
				duration = controller.video.duration;
			}
			var showHours : Boolean = Math.floor(duration / 3600) > 0 ? true : false;

			var updateString : String = TimeUtils.formatSeconds(duration, showHours);
			var beginIndex : uint = updateString.length;

			updateString += (!controller.video.isLive) ? (" " + SYMBOL + " " + TimeUtils.formatSeconds(duration, showHours)) : (" " + SYMBOL + " " + LIVE);

			tFormat.color = colorScheme.clockInactiveColor;
			updateClock(updateString, tFormat, beginIndex);
		}

		private function updateClock(str : String, fmt : TextFormat = null, beginIndex : int = 0) : void {
			tf.text = str;

			if (fmt != null) {
				tf.setTextFormat(fmt, beginIndex, tf.text.length);
			}

			layout();
		}
	}
}
