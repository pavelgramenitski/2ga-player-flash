package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author Daniel
	 */
	public class Fullscreen extends Sprite {
		private var controller : IController;
		private var colorScheme : IColors;
		private var enterIcon : DisplayObject;
		private var exitIcon : DisplayObject;
		private var bg : ColorBackground;
		private var _width : Number = 44;
		private var _height : Number = 31;

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

		public function Fullscreen(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;

			buttonMode = true;
			mouseChildren = false;

			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);

			createChildren();

			controller.addEventListener(ResizeEvent.ENTER_FULLSCREEN, enterFullscreenHandler);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreenHandler);

			setStyle();
			layout();
		}

		private function createChildren() : void {
			var Texture : Class;
			var rect : Rectangle;

			bg = new ColorBackground(colorScheme.baseCT, colorScheme.baseAlpha, false, false, 0);
			addChild(bg);
			bg.width = this.width;
			bg.height = this.height;

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.FullScreenEnterIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.FullScreenEnterIcon);
			enterIcon = new Texture();
			enterIcon.width = rect.width;
			enterIcon.height = rect.height;
			addChild(enterIcon);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.FullScreenExitIcon);
			rect = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.FullScreenExitIcon);
			exitIcon = new Texture();
			exitIcon.width = rect.width;
			exitIcon.height = rect.height;
			addChild(exitIcon);

			exitIcon.visible = false;
		}

		private function disposeChildren() : void {
			bg.dispose();
			// enterIcon.bitmapData.dispose();
			// exitIcon.bitmapData.dispose();
		}

		private function layout() : void {
			bg.width = _width;
			bg.height = _height;
			centerDisplayObject(enterIcon);
			centerDisplayObject(exitIcon);
		}

		private function setStyle() : void {
			enterIcon.transform.colorTransform = colorScheme.primaryCT;
			exitIcon.transform.colorTransform = colorScheme.primaryCT;
			bg.transform.colorTransform = colorScheme.baseCT;
		}

		private function enterFullscreenHandler(e : ResizeEvent) : void {
			enterIcon.visible = false;
			exitIcon.visible = true;
		}

		private function exitFullscreenHandler(e : ResizeEvent) : void {
			enterIcon.visible = true;
			exitIcon.visible = false;
			outHandler();
		}

		private function clickHandler(e : MouseEvent) : void {
			controller.fullScreen = !controller.fullScreen;
		}

		private function overHandler(e : MouseEvent) : void {
			if (!Skin.isAdvert) {
				bg.transform.colorTransform = colorScheme.highlightCT;
			} else {
				bg.transform.colorTransform = colorScheme.advertCT;
			}
		}

		private function outHandler(e : MouseEvent = null) : void {
			bg.transform.colorTransform = colorScheme.baseCT;
		}

		public function dispose() : void {
			disposeChildren();
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);

			colorScheme = null;

			controller.removeEventListener(ResizeEvent.ENTER_FULLSCREEN, enterFullscreenHandler);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreenHandler);
			controller = null;
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.floor(this.width / 2 - target.width / 2) ;
			target.y = Math.floor(this.height / 2 - target.height / 2);
		}
	}
}
