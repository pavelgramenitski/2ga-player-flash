package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.LoopModeEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.LoopMode;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author KJR
	 */
	public class PlaylistBarLoopButton extends Sprite {
		private static const INACTIVE_STATE : int = 0;
		private static const LIST_STATE : int = 1;
		private static const VIDEO_STATE : int = 2 ;
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : ColorBackground;
		private var listIcon : DisplayObject;
		private var videoIcon : DisplayObject;
		private var _state : int;
		private var _enabled : Boolean = true;
		private var _width : Number = 38;
		private var _height : Number = 24;

		public function PlaylistBarLoopButton(controller : IController) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			buttonMode = true;
			mouseChildren = false;

			createChildren();
			registerEventListeners();
			layout();
			setStyle();
			setInitialDisplayState();
		}

		public function dispose() : void {
			unregisterEventListeners();
			removeChildren(0, numChildren - 1);
			colorScheme = null;
			bg = null;
			listIcon = null;
			videoIcon = null;
			controller = null;
		}

		override public function set width(w : Number) : void {
			_width = w;
			layout();
		}

		override public function set height(h : Number) : void {
			_height = h;
			layout();
		}

		public function get enabled() : Boolean {
			return _enabled;
		}

		public function set enabled(value : Boolean) : void {
			_enabled = value;
			_enabled ? enableButton() : disableButton();
		}

		private function clickHandler(e : MouseEvent) : void {
			switch(_state) {
				case INACTIVE_STATE:
					controller.dispatchEvent(new LoopButtonEvent(LoopButtonEvent.LOOP_LIST));
					break;
				case LIST_STATE:
					controller.dispatchEvent(new LoopButtonEvent(LoopButtonEvent.LOOP_VIDEO));
					break;
				case VIDEO_STATE:
					controller.dispatchEvent(new LoopButtonEvent(LoopButtonEvent.LOOP_INACTIVE));
					break;
			}
		}

		private function loopModeEventChangeHandler(event : LoopModeEvent) : void {
			switch(controller.loopMode) {
				case LoopMode.NONE :
					setDisplayState(INACTIVE_STATE);
					break;
				case LoopMode.PLAYLIST :
					setDisplayState(LIST_STATE);
					break;
				case LoopMode.VIDEO :
					setDisplayState(VIDEO_STATE);
					break;
			}
		}

		private function overHandler(e : MouseEvent) : void {
			bg.setColorTansform(colorScheme.highlightCT) ;
		}

		private function outHandler(e : MouseEvent = null) : void {
			bg.setColorTansform(colorScheme.baseCT) ;
		}

		private function exitFullScreenHandler(e : ResizeEvent) : void {
			if (_state != INACTIVE_STATE) {
				outHandler();
			}
		}

		private function createChildren() : void {
			var Texture : Class;
			var rect : Rectangle;

			bg = new ColorBackground(colorScheme.baseCT, colorScheme.baseAlpha, true, false);
			addChild(bg);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlaylistLoopIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlaylistLoopIcon);
			listIcon = new Texture();
			listIcon.width = rect.width;
			listIcon.height = rect.height;
			addChild(listIcon);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlaylistLoopVideoIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlaylistLoopVideoIcon);
			videoIcon = new Texture();
			videoIcon.width = rect.width;
			videoIcon.height = rect.height;
			addChild(videoIcon);
		}

		private function layout() : void {
			bg.width = this._width;
			bg.height = this._height;
			centerIcons();
		}

		private function setStyle() : void {
			listIcon.transform.colorTransform = colorScheme.primaryCT;
			videoIcon.transform.colorTransform = colorScheme.primaryCT;
		}

		private function centerIcons() : void {
			listIcon.x = Math.round(_width / 2 - listIcon.width / 2);
			listIcon.y = Math.round(_height / 2 - listIcon.height / 2);

			videoIcon.x = Math.round(_width / 2 - videoIcon.width / 2);
			videoIcon.y = Math.round(_height / 2 - videoIcon.width / 2);
		}

		private function setInitialDisplayState() : void {
			controller.dispatchEvent(new LoopModeEvent(LoopModeEvent.CHANGE));
		}

		private function setDisplayState(state : Number) : void {
			_state = state;
			videoIcon.visible = (_state == VIDEO_STATE) ? true : false;
			listIcon.visible = !videoIcon.visible;
			listIcon.transform.colorTransform = (_state == INACTIVE_STATE) ? colorScheme.inactiveCT : colorScheme.primaryCT;
		}

		private function registerEventListeners() : void {
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.addEventListener(LoopModeEvent.CHANGE, loopModeEventChangeHandler);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullScreenHandler);
		}

		private function unregisterEventListeners() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.removeEventListener(LoopModeEvent.CHANGE, loopModeEventChangeHandler);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullScreenHandler);
		}

		private function enableButton() : void {
			buttonMode = true;
			bg.setColorTansform(colorScheme.baseCT);
		}

		private function disableButton() : void {
			buttonMode = false;
			bg.setColorTansform(colorScheme.inactiveCT);
		}
	}
}
