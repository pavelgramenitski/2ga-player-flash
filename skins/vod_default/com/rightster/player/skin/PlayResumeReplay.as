package com.rightster.player.skin {
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Quintic;
	import com.gskinner.motion.plugins.AutoHidePlugin;
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
	public class PlayResumeReplay extends MovieClip {
		private static const OVERALL_BG_ASSET : String = "overall_bg_mc";
		private static const PLAY_ASSET : String = "play_mc";
		private static const RESUME_ASSET : String = "resume_mc";
		private static const REPLAY_ASSET : String = "replay_mc";
		private static const BG_ASSET : String = "bg_mc";
		private static const CHROME_HEIGHT_ADJUSTOR : Number = 40;
		private static const ANIMATION_DURATION : Number = 0.8;
		private var controller : IController;
		private var playAsset : Sprite;
		private var resumeAsset : Sprite;
		private var replayAsset : Sprite;
		private var bgAsset : Sprite;
		private var overallBgAsset : Sprite;
		private var previousState : int;

		public function PlayResumeReplay(controller : IController) : void {
			this.controller = controller;

			AutoHidePlugin.install();

			playAsset = this[PLAY_ASSET];
			resumeAsset = this[RESUME_ASSET];
			replayAsset = this[REPLAY_ASSET];
			bgAsset = this[BG_ASSET];
			overallBgAsset = this[OVERALL_BG_ASSET];
			overallBgAsset.alpha = 0;
			overallBgAsset.visible = false;
			
			playAsset.visible = false;
			bgAsset.visible = false;
			resumeAsset.visible = false;
			replayAsset.visible = false;

			bgAsset.buttonMode = true;
			playAsset.mouseEnabled = false;
			resumeAsset.mouseEnabled = false;
			replayAsset.mouseEnabled = false;

			controller.screen.addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			bgAsset.addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			bgAsset.addEventListener(MouseEvent.MOUSE_OUT, outHandler);

			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			setStyle();
			resize();
		}

		private function setStyle() : void {
			playAsset.transform.colorTransform = Colors.primaryCT;
			resumeAsset.transform.colorTransform = Colors.primaryCT;
			replayAsset.transform.colorTransform = Colors.primaryCT;
			bgAsset.transform.colorTransform = Colors.baseCT;
			bgAsset.alpha = Colors.baseAlpha;
		}

		private function resize(e : ResizeEvent = null) : void {
			overallBgAsset.x = overallBgAsset.y = 0;
			overallBgAsset.width = controller.width;
			overallBgAsset.height = controller.height;

			bgAsset.x = playAsset.x = resumeAsset.x = replayAsset.x = Math.round(controller.width / 2);
			bgAsset.y = playAsset.y = resumeAsset.y = replayAsset.y = Math.round((controller.height - CHROME_HEIGHT_ADJUSTOR) / 2);
		}

		private function stateChange(e : PlayerStateEvent) : void {
			previousState = e.previousState;
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.PLAYER_BUFFERING :
					playAsset.visible = false;
					resumeAsset.visible = false;
					replayAsset.visible = false;
					bgAsset.visible = false;
					
					//overallBgAsset.visible = true;
					break;
				case PlayerState.VIDEO_CUED :
					playAsset.visible = true;
					bgAsset.visible = true;
					//overallBgAsset.visible = true;
					break;
				case PlayerState.VIDEO_PLAYING :
					playAsset.visible = false;
					resumeAsset.visible = false;
					replayAsset.visible = false;
					bgAsset.visible = false;
					//overallBgAsset.visible = true;
					animate(playAsset);
					break;
				case PlayerState.AD_PLAYING :
					playAsset.visible = false;
					resumeAsset.visible = false;
					replayAsset.visible = false;
					bgAsset.visible = false;
					//overallBgAsset.visible = false;
					animate(playAsset);
					break;
				case PlayerState.VIDEO_PAUSED :
					animate(resumeAsset);
					break;
				case PlayerState.AD_PAUSED :
					//overallBgAsset.visible = true;
					animate(resumeAsset);
					break;
				case PlayerState.PLAYLIST_ENDED :
					replayAsset.visible = true;
					bgAsset.visible = true;
					break;
			}
		}

		private function animate(asset : Sprite) : void {
			asset.scaleX = asset.scaleY = asset.alpha = 1;
			GTweener.to(asset, ANIMATION_DURATION, {scaleX:2, scaleY:2, alpha:0}, {ease:Quintic.easeOut}, {AutoHideEnabled:true});
		}

		private function clickHandler(e : MouseEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_PLAYING :
				case PlayerState.AD_PLAYING :
					controller.pauseVideo();
					break;
				case PlayerState.VIDEO_CUED :
				case PlayerState.VIDEO_PAUSED :
				case PlayerState.AD_PAUSED :
				case PlayerState.PLAYLIST_ENDED :
						controller.playVideo();
					break;
				case PlayerState.PLAYER_BUFFERING :
					if (previousState == PlayerState.VIDEO_PLAYING || previousState == PlayerState.AD_PLAYING) {
						controller.pauseVideo();
					}
					break;
			}
		}

		private function overHandler(e : MouseEvent) : void {
			bgAsset.transform.colorTransform = Colors.highlightCT;
			bgAsset.alpha = Colors.highlightAlpha;
		}

		private function outHandler(e : MouseEvent) : void {
			bgAsset.transform.colorTransform = Colors.baseCT;
			bgAsset.alpha = Colors.baseAlpha;
		}

		public function dispose() : void {
			controller.screen.removeEventListener(MouseEvent.CLICK, clickHandler);
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.removeEventListener(ResizeEvent.RESIZE, resize);
			
			removeEventListener(MouseEvent.CLICK, clickHandler);
			bgAsset.removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			bgAsset.removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			controller = null;
		}
	}
}
