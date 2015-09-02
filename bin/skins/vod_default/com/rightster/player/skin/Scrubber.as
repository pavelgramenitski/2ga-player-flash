package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MediaProviderEvent;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;

	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import flash.text.TextField;

	/**
	 * @author Daniel
	 */
	public class Scrubber extends MovieClip {
		private static const BG_ASSET : String = "bg_mc";
		private static const BG_SHADOW_ASSET : String = "bg_shadow_mc";
		private static const BUFFER_ASSET : String = "buffer_mc";
		private static const BUFFER_SHADOW_ASSET : String = "buffer_shadow_mc";
		private static const PROGRESS_ASSET : String = "progress_mc";
		private static const SCRUBBER_ASSET : String = "scrubber_mc";
		private static const INSIDE_ASSET : String = "inside_mc";
		private static const OUTSIDE_ASSET : String = "outside_mc";
		private static const TOOLTIP_ASSET : String = "tooltip_mc";
		private static const TOOLTIP_TEXT_ASSET : String = "tooltip_text";
		private static const TOOLTIP_BG_ASSET : String = "tooltip_bg";
		private static const CLICK_INDICATOR : String = "click_indicator";
		private static const TOOLTIP_LR_PADDING : Number = 5;
		private static const UPDATE_RATE : Number = 1000/60;
		private static const DRIVER_WIDTH : Number = 9;
		private static const SKIP_UPDATES_AFTER_DRAG : int = 5; //after dragging skip few updates 
		private static const SKIP_UPDATES_AFTER_QUALITY_CHANGE : int = 5; //after quality change skip few updates 
				
		private var controller : IController;
		private var _width : Number;
		private var bgBar  : Sprite;
		private var bgShadow : Sprite;
		private var bufferBar : Sprite;
		private var bufferShadow : Sprite;
		private var progressBar : Sprite;
		private var scrubber : Sprite;
		private var scrubberInside : Sprite;
		private var scrubberOutside : Sprite;
		private var toolTip : Sprite;
		private var toolTipText : TextField;
		private var toolTipBg : Sprite;
		private var clickIndicator : Sprite;
		private var timer : Timer;
		private var progress : Number;
		private var buffer : Number;
		private var dragging : Boolean;
		private var pausedForDragging : Boolean;
		private var skipUpdates : int =  0;
		
		override public function set width(n : Number) : void {
			_width = n;
			bgBar.width = _width;
			
			stateChange();
		}
		
		override public function get width() : Number {
			return _width;
		}
		
		public function Scrubber(controller : IController) : void {
			this.controller = controller;
			this.blendMode = BlendMode.LAYER;
			
			bgBar = this[BG_ASSET];
			bufferBar = this[BUFFER_ASSET];
			progressBar = this[PROGRESS_ASSET];
			bgShadow = this[BG_SHADOW_ASSET];
			bufferShadow = this[BUFFER_SHADOW_ASSET];
			scrubber = this[SCRUBBER_ASSET];
			scrubberInside = scrubber[INSIDE_ASSET];
			scrubberOutside = scrubber[OUTSIDE_ASSET];
			toolTip = this[TOOLTIP_ASSET];
			toolTip.visible = false;
			toolTipText = toolTip[TOOLTIP_TEXT_ASSET];
			toolTipBg = toolTip[TOOLTIP_BG_ASSET];
			clickIndicator = this[CLICK_INDICATOR];
			clickIndicator.visible = false;
			
			controller.stage.addEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			controller.stage.addEventListener(MouseEvent.ROLL_OUT, _stopDrag);
			controller.stage.addEventListener(Event.MOUSE_LEAVE, _stopDrag);
			 
			addEventListener(MouseEvent.MOUSE_DOWN, bgDown);
			
			addEventListener(MouseEvent.MOUSE_MOVE, bgOverOutMove);
			addEventListener(MouseEvent.MOUSE_OVER, bgOverOutMove);
			addEventListener(MouseEvent.MOUSE_OUT, bgOverOutMove);
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, _startDrag);	
			mouseChildren = mouseEnabled = false;
			useHandCursor = buttonMode = true;
				
			startPosition();
			
			timer = new Timer(UPDATE_RATE, 0);
			timer.addEventListener(TimerEvent.TIMER, update);
			
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(PlaybackQualityEvent.CHANGE, qualityChange);
			controller.addEventListener(MediaProviderEvent.META_DATA, onMediaMetaData);
			
			
			setStyle();
		}
		
		private function setStyle() : void {
			progressBar.transform.colorTransform = Colors.primaryCT;		
			scrubberInside.transform.colorTransform = Colors.primaryCT;	
			bufferBar.transform.colorTransform = Colors.inactiveCT;		
		}
		
		private function onMediaMetaData(e : MediaProviderEvent) : void {
			if (controller.getDuration() > 0) {
				mouseChildren = mouseEnabled = true;
			}
		}
		
		private function qualityChange(e : PlaybackQualityEvent) : void {
			skipUpdates = SKIP_UPDATES_AFTER_QUALITY_CHANGE;
		}
		
		private function stateChange(e : PlayerStateEvent = null) : void {
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
				    //handled in onMetaData
					//mouseChildren = mouseEnabled = true;
					//useHandCursor = buttonMode = true;
					scrubber.visible = true;	
					timer.start();
					update();
				break;
				
				case PlayerState.VIDEO_ENDED :
				case PlayerState.PLAYLIST_ENDED :
					timer.stop();
					endPosition();
				break;
				default :
					update();
			}
		}

		private function update(e : TimerEvent = null) : void {
			//var startTime : Number = controller.getVideoStartBytes() / controller.getVideoBytesTotal();
			progress = controller.getCurrentTime() / controller.getDuration();
			progress = progress > 1 ? 1 : progress;
			buffer = controller.getVideoBytesLoaded() / controller.getVideoBytesTotal();
			buffer = buffer > 1 ? 1 : buffer;
			
			if (!dragging) {
				if (skipUpdates > 0) {
					skipUpdates--;
				} else {
					scrubber.x = Math.round(progress * (_width - DRIVER_WIDTH));
					progressBar.width = progress * (_width - DRIVER_WIDTH);
				}
			}
			bufferShadow.width = bufferBar.width = buffer * (_width - DRIVER_WIDTH) + DRIVER_WIDTH;
			bgShadow.x = _width;
			bgShadow.width = (_width - bufferBar.width - 3) < 0 ? 0 : (_width - bufferBar.width - 3);
		}
		
		private function startPosition() : void {
			scrubber.visible = false;
			scrubber.x = 0;
			progressBar.width = 0;			
			bufferShadow.width = bufferBar.width = 0;	
			bgShadow.x = _width;	
			bgShadow.width = _width - 3;	
		}

		private function endPosition() : void {
			scrubber.x = _width - DRIVER_WIDTH;
			progressBar.width = _width;			
			bufferShadow.width = bufferBar.width = _width;		
			bgShadow.width = 0;	
		}

		private function bgDown(e : MouseEvent) : void {
			scrubber.x = this.mouseX;
			clickIndicator.visible = false;
			var ratio : Number = (scrubber.x / _width < 1) ? scrubber.x / _width : 1;
			controller.seekTo(ratio * controller.getDuration(), true);
		}
		private function bgOverOutMove(evt:MouseEvent):void{
			toolTip.x = this.mouseX+2.5;
		
			var ratio : Number = (this.mouseX / _width < 1) ? this.mouseX / _width : 1;
			var duration : Number = Number(Math.round(controller.getDuration()));
			var showHours : Boolean = Math.floor(duration / 3600) > 0 ? true : false;
			
			var toolTipTextValue : String = formatDigits(ratio*duration, showHours);
			if(ratio<0){
				if(showHours){
					toolTipTextValue = "0:00:00";
				}else{
					toolTipTextValue = "00:00";
				}
			}
			toolTipText.htmlText = toolTipTextValue;
			toolTipText.autoSize = "center";
			
			toolTipBg.width = toolTipText.textWidth + (TOOLTIP_LR_PADDING*2);
			toolTipText.x = Number((toolTipBg.width - toolTipText.textWidth)/2)-2;
			
			var eventType : String = String(evt.type);
			switch(eventType){
				case "mouseOver":
				case "mouseMove":
					clickIndicator.x = this.mouseX;
					clickIndicator.visible = true;
					toolTip.visible = true;
					var maxRight : Number = Number(bgBar.width - clickIndicator.width);
					if(clickIndicator.x >= maxRight){
						clickIndicator.x = maxRight;
						toolTip.x = maxRight+2.5;
					}
					if(clickIndicator.x <= 1){
						clickIndicator.x = clickIndicator.x - 1;
					}
				break;
				
				case "mouseOut":
				default:
					toolTip.visible = false;
					clickIndicator.visible = false;
				break;
			}
		}

		private function _startDrag(e : MouseEvent) : void {
			if (controller.playerState != PlayerState.VIDEO_PAUSED) {
				pausedForDragging = true;
				controller.pauseVideo();
			}
			e.stopImmediatePropagation();
			dragging = true;
			skipUpdates = SKIP_UPDATES_AFTER_DRAG;
			controller.stage.addEventListener(MouseEvent.MOUSE_MOVE, _doDrag);
		}

		private function _doDrag(event : MouseEvent) : void {
			var posX : Number = this.mouseX < 0 ? 0 : this.mouseX > (_width - DRIVER_WIDTH) ? (_width - DRIVER_WIDTH) : this.mouseX;
			progressBar.width = scrubber.x = posX;
			if (posX > buffer * _width) {
				bufferShadow.width = bufferBar.width = posX;
				bgShadow.width = (_width - posX + DRIVER_WIDTH - 3) < 0 ? 0 : (_width - posX + DRIVER_WIDTH - 3);
			} else {
				bufferShadow.width = bufferBar.width = buffer * (_width - DRIVER_WIDTH) + DRIVER_WIDTH;
				bgShadow.width = (_width - bufferBar.width - 3) < 0 ? 0 : (_width - bufferBar.width - 3);
			}
		}
		
		
		private function _stopDrag(e : Event) : void {
			if (dragging) {
				controller.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _doDrag);
				dragging = false;
				var ratio : Number = (scrubber.x / _width < 1) ? scrubber.x / _width : 1;
				controller.seekTo(ratio * controller.getDuration(), true);
				if (pausedForDragging) {
					pausedForDragging = false;
					controller.playVideo();
				}
			}
			clickIndicator.visible = false;
		}
		
		private function formatDigits(seconds : Number, showHours : Boolean) : String {
			var hr : Number = Math.floor(seconds / 3600);
			var min : Number = Math.floor((seconds % 3600)/60);
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

		public function dispose() : void {		
			timer.stop();
			timer.removeEventListener(TimerEvent.TIMER, update);
			timer = null;
			
			controller.stage.removeEventListener(MouseEvent.MOUSE_UP, _stopDrag);
			controller.stage.removeEventListener(MouseEvent.ROLL_OUT, _stopDrag);
			controller.stage.removeEventListener(Event.MOUSE_LEAVE, _stopDrag);
			controller.stage.removeEventListener(MouseEvent.MOUSE_MOVE, _doDrag);
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.removeEventListener(PlaybackQualityEvent.CHANGE, qualityChange);
			controller.removeEventListener(MediaProviderEvent.META_DATA, onMediaMetaData);
			
			removeEventListener(MouseEvent.MOUSE_OUT, bgOverOutMove);
			controller = null;
		}
	}
}