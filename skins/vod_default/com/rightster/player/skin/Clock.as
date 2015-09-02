package com.rightster.player.skin {
	import com.rightster.utils.TimeUtils;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;
	import flash.display.MovieClip;
	import flash.events.TimerEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.utils.Timer;


	/**
	 * @author Daniel
	 */
	public class Clock extends MovieClip {
		private static const CLOCK_ASSET : String = "clock_txt";
		private static const SYMBOL : String = ' / ';
		private static const UPDATE_RATE : Number = 1000;
		private static const LIVE : String = "Live";
		
		private var controller : IController;
		private var clock : TextField;
		private var format : TextFormat;
		private var timer : Timer;
		
		public function Clock(controller : IController) : void {
			this.controller = controller;
			
			clock = this[CLOCK_ASSET];
			clock.selectable = false;
			
			format = new TextFormat();
			clock.text = "";
			
			timer = new Timer(UPDATE_RATE, 0);
			timer.addEventListener(TimerEvent.TIMER, update);
			
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			
			setStyle();
		}
		
		private function setStyle() : void {
			format.color = Colors.primaryColor;
			clock.defaultTextFormat = format;
		}
		
		
		private function stateChange(e : PlayerStateEvent) : void {
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
					timer.stop();
					update();
				break;
			}
		}
		
		private function update(e : TimerEvent = null) : void {
			var current : Number = Math.round(controller.getCurrentTime());
			var duration : Number = Math.round(controller.getDuration());
			var showHours : Boolean = Math.floor(duration / 3600) > 0 ? true : false;
			
			var updateString : String = TimeUtils.formatSeconds(current, showHours);
			var beginIndex : uint = updateString.length;
			
			updateString += (!controller.video.isLive) ? (" " + SYMBOL + " " + TimeUtils.formatSeconds(duration, showHours)) : (" " + SYMBOL + " " + LIVE);
			
			format.color = Colors.inactiveColor;
			updateClock(updateString, format, beginIndex);
		}
		
		private function updateClock(str : String, fmt : TextFormat = null, beginIndex : int = 0) : void {
			clock.text = str;
			
			if(fmt != null) {
				clock.setTextFormat(fmt, beginIndex, clock.text.length);
			}
		}
		
		public function dispose() : void {			
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, update);
			timer = null;
			
			clock.text = ""; 
			clock = null;
			
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller = null;
		}
	}
}
