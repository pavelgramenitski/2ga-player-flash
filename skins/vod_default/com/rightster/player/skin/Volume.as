package com.rightster.player.skin {
	import com.rightster.utils.Log;
	import com.rightster.utils.VolumeUtils;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.events.VolumeEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;


	/**
	 * @author Daniel
	 */
	public class Volume extends MovieClip {
		private static const SPEAKER_ASSET : String = "speaker_mc";
		private static const BG_ASSET : String = "bg_mc";
		private static const BAR_ASSET : String = "b";
		
		private static const SPEAKER_STEPS : int = 2;
		private static const VOLUME_BARS : int = 10;
		private static const BARS_WAVE_AMP : Number = 4;
		private static const BARS_WAVE_LEN : Number = 8;
		private static const FULL_VOLUME : Number = 100;
		private static const ZERO_VOLUME : Number = 0;
		
		private var controller : IController;
		private var speaker : MovieClip;
		private var bgAsset : Sprite;
		private var bars : Array;
		private var isDown:Boolean;
		
		public function Volume(controller : IController) : void {
			this.controller = controller;
			
			speaker = this[SPEAKER_ASSET];
			bgAsset = this[BG_ASSET];
			bars = [];
			bgAsset.visible = true;
			bgAsset.alpha = 0;
			
			for (var i : int = 0; i < VOLUME_BARS; i++) {
				(this[BAR_ASSET + i] as Sprite).height = 2 + i * 2;
				(this[BAR_ASSET + i] as Sprite).mouseEnabled = false;
				bars.push(this[BAR_ASSET + i] as Sprite);
			}
			
			bgAsset.addEventListener(MouseEvent.CLICK, clickHandler);
			speaker.addEventListener(MouseEvent.CLICK, muteHandler);
			speaker.addEventListener(MouseEvent.MOUSE_OVER, speakerOverHandler);
			speaker.addEventListener(MouseEvent.MOUSE_OUT, speakerOutHandler);
			
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.MOUSE_UP, outHandler);
			this.controller.stage.addEventListener(MouseEvent.MOUSE_UP, outHandler);
			buttonMode = true;
			visible = false;
			
			controller.addEventListener(VolumeEvent.CHANGE, setSpeaker);
			controller.addEventListener(VolumeEvent.MUTE, setSpeaker);
			controller.addEventListener(VolumeEvent.UNMUTE, setSpeaker);
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			
			setStyle();
		}

		private function speakerOutHandler(event : MouseEvent) : void {
			speaker.transform.colorTransform = Colors.primaryCT;
		}

		private function speakerOverHandler(event : MouseEvent) : void {
			speaker.transform.colorTransform = Colors.highlightCT;
		}

		private function setStyle() : void {
			speaker.transform.colorTransform = Colors.primaryCT;
			bgAsset.alpha = 0;
		}

		private function stateChange(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					setSpeaker();
					visible = true;
				break;
			}
		}
	
		private function muteHandler(e : MouseEvent) : void {
			if (controller.isMuted()) {
				controller.unMute();
			} else {
				controller.mute();
			}
		}
		
		private function clickHandler(event : MouseEvent = null) : void {
			if (this.mouseX < (bars[0] as Sprite).x) {
				controller.setVolume(ZERO_VOLUME);		
			} else if (this.mouseX > (bars[9] as Sprite).x) {
				controller.setVolume(FULL_VOLUME);		
			} else {
				var vol : Number = (this.mouseX - (bars[0] as Sprite).x) / ((bars[9] as Sprite).x - (bars[0] as Sprite).x);
				controller.setVolume(Math.round(VolumeUtils.easeInQuad(vol * FULL_VOLUME)));
			}
		}
		private function mouseDownHandler(evt:MouseEvent):void{
			addEventListener(MouseEvent.MOUSE_MOVE, moveHandler, false, 0 ,true);
			isDown = true;
		}
		
		private function overHandler(e : MouseEvent) : void {
			addEventListener(MouseEvent.MOUSE_MOVE, moveHandler, false, 0 ,true);
		}
	
		private function outHandler(e : MouseEvent = null) : void {
			removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
			for (var i : int = 0; i < VOLUME_BARS; i++) {
				(bars[i] as Sprite).height = 2 + i * 2;
			}
			isDown = false;
		}

		private function moveHandler(event : MouseEvent) : void {
			var d : Number;
			for (var i : int = 0; i < VOLUME_BARS; i++) {
				d = Math.abs((bars[i] as Sprite).x - mouseX);
				d = d > BARS_WAVE_LEN ? BARS_WAVE_LEN : d;
				(bars[i] as Sprite).height = 2 + i * 2 + ((BARS_WAVE_LEN - d) / BARS_WAVE_LEN) * BARS_WAVE_AMP;
			}
			if (isDown) {
				clickHandler();
			}
		}
		
		private function setSpeaker(e : VolumeEvent = null) : void {
			if (controller.isMuted()) {
				speaker.gotoAndStop(1);
			} else {
				speaker.gotoAndStop(Math.round(VolumeUtils.formatToCodeLevel(VolumeUtils.reverseEiQ(controller.getVolume())) * SPEAKER_STEPS) + 2);
			}
			for (var i : int = 0; i < VOLUME_BARS; i++) {
				if (i < Math.round(VolumeUtils.formatToCodeLevel(VolumeUtils.reverseEiQ(controller.getVolume())) * VOLUME_BARS) && !controller.isMuted()) {
					(bars[i] as Sprite).transform.colorTransform = Colors.primaryCT;
				} else {
					(bars[i] as Sprite).transform.colorTransform = Colors.inactiveCT;
				}
			}
		}
		
		private function exitFullscreen(e : ResizeEvent) : void {
			outHandler();
		}

		public function dispose() : void {
			bgAsset.removeEventListener(MouseEvent.CLICK, clickHandler);
			speaker.removeEventListener(MouseEvent.CLICK, muteHandler);
			speaker.removeEventListener(MouseEvent.MOUSE_OVER, speakerOverHandler);
			speaker.removeEventListener(MouseEvent.MOUSE_OUT, speakerOutHandler);
			
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			removeEventListener(MouseEvent.MOUSE_UP, outHandler);
				
			controller.removeEventListener(VolumeEvent.CHANGE, setSpeaker);		
			controller.removeEventListener(VolumeEvent.MUTE, setSpeaker);		
			controller.removeEventListener(VolumeEvent.UNMUTE, setSpeaker);		
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			controller = null;
		}
	}
}
