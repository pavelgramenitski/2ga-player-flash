package com.rightster.player.skin {
	import com.gskinner.motion.GTweener;
	import com.gskinner.motion.easing.Quintic;
	import com.gskinner.motion.plugins.AutoHidePlugin;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author KJR
	 */
	public class PlayReplay extends Sprite {
		private static const CHROME_HEIGHT_ADJUSTOR : Number = 0;
		private static const ANIMATION_DURATION : Number = 0.5;
		private static const MIN_WIDTH : Number = 55;
		private static const MAX_WIDTH : Number = 80;
		private var controller : IController;
		private var colorScheme : IColors;
		private var playIcon : DisplayObject;
		private var pauseIcon : DisplayObject;
		private var replayIcon : DisplayObject;
		private var bg : ColorBackground;
		private var screen : ColorBackground;
		private var previousState : int;

		public function PlayReplay(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			AutoHidePlugin.install();
			mouseChildren = false;
			buttonMode = true;
			createChildren();
			registerEventHandlers();
			setStyle();
			setInitialDisplayState();
			resizeHandler(new ResizeEvent(ResizeEvent.RESIZE));
		}

		public function dispose() : void {
			unregisterEventHandlers();
			disposeChildren();
			colorScheme = null;
			controller = null;
		}

		private function resizeHandler(evt : ResizeEvent) : void {
			screen.x = screen.y = 0;
			screen.width = controller.width;
			screen.height = controller.height;

			// centre
			centerDisplayObject(bg);
			centerDisplayObject(playIcon);
			centerDisplayObject(pauseIcon);
			centerDisplayObject(replayIcon);
		}

		private function playerStateEventHandler(e : PlayerStateEvent) : void {
			previousState = e.previousState;
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.PLAYER_BUFFERING :
					playIcon.visible = false;
					pauseIcon.visible = false;
					replayIcon.visible = false;
					bg.visible = false;
					break;
				case PlayerState.VIDEO_CUED :
					playIcon.visible = true;
					bg.visible = true;
					break;
				case PlayerState.VIDEO_PLAYING :
					playIcon.visible = false;
					pauseIcon.visible = false;
					replayIcon.visible = false;
					bg.visible = false;
					break;
				case PlayerState.AD_PLAYING :
					playIcon.visible = false;
					pauseIcon.visible = false;
					replayIcon.visible = false;
					bg.visible = false;
					break;
				case PlayerState.VIDEO_PAUSED :
				case PlayerState.AD_PAUSED :
					// nothing
					break;
				case PlayerState.PLAYLIST_ENDED :
					replayIcon.visible = true;
					bg.visible = true;
					fadeIn(bg, replayIcon);
					break;
			}
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
					controller.playVideo();
					break;
				case PlayerState.PLAYLIST_ENDED :
					controller.playVideoAt(0);
					break;
				case PlayerState.PLAYER_BUFFERING :
					if (previousState == PlayerState.VIDEO_PLAYING || previousState == PlayerState.AD_PLAYING) {
						controller.pauseVideo();
					}
					break;
			}
		}

		private function overHandler(e : MouseEvent) : void {
			bg.transform.colorTransform = colorScheme.highlightCT;
			bg.alpha = colorScheme.highlightAlpha;
		}

		private function outHandler(e : MouseEvent) : void {
			bg.transform.colorTransform = colorScheme.baseCT;
			bg.alpha = colorScheme.baseAlpha;
		}

		private function registerEventHandlers() : void {
			controller.screen.addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.addEventListener(ResizeEvent.RESIZE, resizeHandler);
		}

		private function unregisterEventHandlers() : void {
			controller.screen.removeEventListener(MouseEvent.CLICK, clickHandler);
			controller.removeEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.removeEventListener(ResizeEvent.RESIZE, resizeHandler);

			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
		}

		private function createChildren() : void {
			var Texture : Class;
			var rect : Rectangle;

			screen = new ColorBackground(colorScheme.advertCT, colorScheme.baseAlpha, false, false, 0);
			screen.width = MAX_WIDTH;
			screen.height = MIN_WIDTH;
			addChild(screen);

			bg = new ColorBackground(colorScheme.advertCT, colorScheme.baseAlpha, false, false, 0);
			bg.width = MAX_WIDTH;
			bg.height = MIN_WIDTH;
			addChild(bg);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlayIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlayIconLarge);
			playIcon = new Texture();
			playIcon.width = rect.width;
			playIcon.height = rect.height;
			addChild(playIcon);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PauseIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PauseIconLarge);
			pauseIcon = new Texture();
			pauseIcon.width = rect.width;
			pauseIcon.height = rect.height;
			addChild(pauseIcon);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.ReplayIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.ReplayIconLarge);
			replayIcon = new Texture();
			replayIcon.width = rect.width;
			replayIcon.height = rect.height;
			addChild(replayIcon);
		}

		private function disposeChildren() : void {
			screen.dispose();
			bg.dispose();
		}

		private function setInitialDisplayState() : void {
			screen.alpha = 0;
			screen.visible = false;
			playIcon.visible = false;
			bg.visible = false;
			pauseIcon.visible = false;
			replayIcon.visible = false;
			bg.buttonMode = true;
		}

		private function setStyle() : void {
			playIcon.transform.colorTransform = colorScheme.primaryCT;
			pauseIcon.transform.colorTransform = colorScheme.primaryCT;
			replayIcon.transform.colorTransform = colorScheme.primaryCT;
			bg.transform.colorTransform = colorScheme.baseCT;
			bg.alpha = colorScheme.baseAlpha;
		}

		private function fadeIn(bg : DisplayObject, detail : DisplayObject) : void {
			try {
				GTweener.to(bg, ANIMATION_DURATION, {alpha:colorScheme.baseAlpha}, {ease:Quintic.easeOut});
				GTweener.to(detail, ANIMATION_DURATION, {alpha:1}, {ease:Quintic.easeOut});
			} catch(error : Error) {
				bg.alpha = colorScheme.baseAlpha;
				detail.alpha = 1;
			}
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.round(controller.width / 2 - target.width / 2) ;
			target.y = Math.round((controller.height - CHROME_HEIGHT_ADJUSTOR) / 2 - target.height / 2);
		}
	}
}
