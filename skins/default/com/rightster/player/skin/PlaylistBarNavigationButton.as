package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author KJR
	 */
	public class PlaylistBarNavigationButton extends Sprite {
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : Sprite;
		private var icon : DisplayObject;
		private var _enabled : Boolean;
		private var _width : Number = 30;
		private var _height : Number = 24;
		private var _gutter : Number = 8;
		private var _direction : int;

		override public function set width(w : Number) : void {
			_width = w;
			draw();
			centerIcon();
		}

		override public function set height(h : Number) : void {
			_height = h;
			draw();
			centerIcon();
		}

		public function get gutter() : Number {
			return _gutter;
		}

		public function set gutter(value : Number) : void {
			_gutter = value;
		}

		public function get direction() : int {
			return _direction;
		}

		public function set direction(value : int) : void {
			_direction = value;
		}

		public function get enabled() : Boolean {
			return _enabled;
		}

		public function set enabled(value : Boolean) : void {
			_enabled = value;
			_enabled ? enableButton() : disableButton();
		}

		public function PlaylistBarNavigationButton(controller : IController, direction : int) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			this.direction = direction;
			mouseChildren = false;
			buttonMode = true;
			_enabled = true;
			createChildren();

			_width = icon.width;

			registerEventListeners();

			draw();
			centerIcon();
		}

		private function createChildren() : void {
			bg = new Sprite();
			addChild(bg);
			var Texture : Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlaylistBarNavigationIcon);
			var rect : Rectangle = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlaylistBarNavigationIcon);
			icon = new Texture();
			icon.width = rect.width;
			icon.height = rect.height;
			addChild(icon);

			icon.transform.colorTransform = colorScheme.primaryCT;
		}

		private function draw() : void {
			bg.graphics.clear();
			bg.graphics.beginFill(0xff0000, 0);
			bg.graphics.drawRect(-_gutter, 0, _width + _gutter * 2, _height);
			bg.graphics.endFill();
		}

		private function centerIcon() : void {
			icon.x = Math.round(_width / 2 - icon.width / 2);
			icon.y = Math.round(_height / 2 - icon.height / 2);
		}

		private function registerEventListeners() : void {
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);

			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
		}

		private function unregisterEventListeners() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);

			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
		}

		private function enableButton() : void {
			buttonMode = true;
			icon.transform.colorTransform = colorScheme.primaryCT;
		}

		private function disableButton() : void {
			buttonMode = false;
			icon.transform.colorTransform = colorScheme.inactiveCT;
		}

		private function clickHandler(e : MouseEvent) : void {
			if (_enabled) {
				outHandler();

				// TODO:scope end / beginning of playlist
				if (direction == 1) {
					controller.nextVideo();
				} else {
					controller.previousVideo();
				}
			}
		}

		private function overHandler(e : MouseEvent) : void {
			if (_enabled) {
				icon.transform.colorTransform = colorScheme.highlightCT;
			}
		}

		private function outHandler(e : MouseEvent = null) : void {
			if (_enabled) {
				icon.transform.colorTransform = colorScheme.primaryCT;
			}
		}

		private function exitFullscreen(e : ResizeEvent) : void {
			if (_enabled) {
				outHandler();
			}
		}

		public function dispose() : void {
			unregisterEventListeners();
			removeChildren(0, numChildren - 1);
			colorScheme = null;
			bg = null;
			icon = null;
			controller = null;
		}
	}
}
