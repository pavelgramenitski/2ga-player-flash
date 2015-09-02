package com.rightster.player.skin {
	import com.rightster.utils.Log;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.PluginEvent;
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
	public class PlayPauseReplay extends Sprite {
		private var controller : IController;
		private var colorScheme : IColors;
		private var playIcon : DisplayObject;
		private var pauseIcon : DisplayObject;
		private var replayIcon : DisplayObject;
		// private var stopIcon : DisplayObject;
		private var bg : ColorBackground;
		private var _width : Number = 44;
		private var _height : Number = 31;

		public function PlayPauseReplay(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			mouseChildren = false;
			buttonMode = true;
			createChildren();
			setStyle();
			registerEventHandlers();
			layout();
		}

		public function dispose() : void {
			unregisterEventHandlers();
			disposeChildren();
			colorScheme = null;
			controller = null;
		}

		override public function set height(h : Number) : void {
			_height = h;
			layout();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set width(w : Number) : void {
			_width = w;
			layout();
		}

		override public function get width() : Number {
			return _width;
		}

		private function playerStateEventHandler(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					outHandler();
					playIcon.visible = true;
					pauseIcon.visible = false;
					replayIcon.visible = false;
					break;
				case PlayerState.VIDEO_PLAYING :
				case PlayerState.AD_PLAYING :
					playIcon.visible = false;
					if (controller.video.isLive) {
						// stopIcon.visible = true;
					} else {
						pauseIcon.visible = true;
					}
					break;
				case PlayerState.VIDEO_PAUSED :
				case PlayerState.AD_PAUSED :
					playIcon.visible = true;
					pauseIcon.visible = false;
					replayIcon.visible = false;
					break;
				case PlayerState.VIDEO_ENDED :
				case PlayerState.AD_ENDED :
					playIcon.visible = true;
					pauseIcon.visible = false;
					replayIcon.visible = false;
					break;
				case PlayerState.PLAYLIST_ENDED:
					playIcon.visible = false;
					pauseIcon.visible = false;
					replayIcon.visible = true;
					break;
			}
		}

		private function clickHandler(e : MouseEvent) : void {
			Log.write("click handler *livestream:" + controller.placement.liveStream);
			if (!Skin.isAdvert && controller.placement.liveStream) {
				return;
			}

			if (playIcon.visible) {
				controller.playVideo();
			} else if (pauseIcon.visible) {
				controller.pauseVideo();
			} else {
				controller.playVideoAt(0);
			}
		}

		private function overHandler(e : MouseEvent) : void {
			if (!Skin.isAdvert && controller.placement.liveStream) {
				return;
			}
			if (!Skin.isAdvert) {
				bg.setColorTansform(colorScheme.highlightCT);
			} else {
				bg.setColorTansform(colorScheme.advertCT);
			}
		}

		private function outHandler(e : MouseEvent = null) : void {
			bg.setColorTansform(colorScheme.baseCT);
		}

		private function exitFullscreen(e : ResizeEvent) : void {
			outHandler();
		}

		private function handlePluginRefreshEvent(event : PluginEvent) : void {
			setInitialDisplayState();
		}

		private function createChildren() : void {
			var Texture : Class;
			var rect : Rectangle;

			bg = new ColorBackground(colorScheme.baseCT, colorScheme.baseAlpha, false, false, 0);
			addChild(bg);
			bg.width = this.width;
			bg.height = this.height;

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlayIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlayIconSmall);
			playIcon = new Texture();
			playIcon.width = rect.width;
			playIcon.height = rect.height;
			addChild(playIcon);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PauseIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PauseIconSmall);
			pauseIcon = new Texture();
			pauseIcon.width = rect.width;
			pauseIcon.height = rect.height;
			addChild(pauseIcon);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.ReplayIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.ReplayIconSmall);
			replayIcon = new Texture();
			replayIcon.width = rect.width;
			replayIcon.height = rect.height;
			addChild(replayIcon);
		}

		private function disposeChildren() : void {
			bg.dispose();
		}

		private function layout() : void {
			bg.height = _height;
			centerDisplayObject(playIcon);
			centerDisplayObject(pauseIcon);
			centerDisplayObject(replayIcon);
		}

		private function setStyle() : void {
			playIcon.transform.colorTransform = colorScheme.primaryCT;
			pauseIcon.transform.colorTransform = colorScheme.primaryCT;
			replayIcon.transform.colorTransform = colorScheme.primaryCT;
			bg.setColorTansform(colorScheme.baseCT);
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.round((_width - target.width) / 2);
			target.y = Math.round((_height - target.height) / 2);
		}

		private function setInitialDisplayState() : void {
			playIcon.visible = false;
			pauseIcon.visible = false;
			replayIcon.visible = false;
		}

		private function registerEventHandlers() : void {
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			controller.addEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}

		private function unregisterEventHandlers() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.removeEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			controller.removeEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}
	}
}
