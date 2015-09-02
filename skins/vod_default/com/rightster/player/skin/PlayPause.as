package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;


	/**
	 * @author Daniel
	 */
	public class PlayPause extends MovieClip {
		
		private static const PLAY_ASSET : String = "play_mc";
		private static const PAUSE_ASSET : String = "pause_mc";
		private static const BG_ASSET : String = "bg_mc";
		
		private var controller : IController;
		private var playAsset : Sprite;
		private var pauseAsset : Sprite;
		private var bgAsset : Sprite;
		
		public function PlayPause(controller : IController) : void {
			this.controller = controller;

			mouseChildren = false;
			
			playAsset = this[PLAY_ASSET];
			pauseAsset = this[PAUSE_ASSET];
			bgAsset = this[BG_ASSET];
			pauseAsset.visible = false;
			
			setStyle();			
				
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
		}		
		
		private function stateChange(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					outHandler();
					playAsset.visible = true;
					pauseAsset.visible = false;
				break;
				
				case PlayerState.VIDEO_PLAYING :
				case PlayerState.AD_PLAYING :
					playAsset.visible = false;
					pauseAsset.visible = true;
				break;
				
				case PlayerState.VIDEO_PAUSED :
				case PlayerState.AD_PAUSED :
					playAsset.visible = true;
					pauseAsset.visible = false;
				break;
				
				case PlayerState.VIDEO_ENDED :
				case PlayerState.AD_ENDED :
					playAsset.visible = true;
					pauseAsset.visible = false;
				break;
			}
		}

		private function setStyle() : void {
			playAsset.transform.colorTransform = Colors.primaryCT;	
			pauseAsset.transform.colorTransform = Colors.primaryCT;
			bgAsset.transform.colorTransform = Colors.baseCT;
			bgAsset.alpha = Colors.baseAlpha;
		}
		
		private function clickHandler(e : MouseEvent) : void {
			if (playAsset.visible) {
				controller.playVideo();
			} else {
				controller.pauseVideo();
			}			
		}
		
		private function overHandler(e : MouseEvent) : void {
			bgAsset.transform.colorTransform = Colors.highlightCT;
			bgAsset.alpha = Colors.highlightAlpha;
		}
	
		private function outHandler(e : MouseEvent = null) : void {
			bgAsset.transform.colorTransform = Colors.baseCT;
			bgAsset.alpha = Colors.baseAlpha;
		}
		
		private function exitFullscreen(e : ResizeEvent) : void {
			outHandler();
		}

		public function dispose() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			controller = null;
		}
	}
}
