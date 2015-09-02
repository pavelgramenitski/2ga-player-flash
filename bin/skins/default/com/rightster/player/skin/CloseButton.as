package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author Ravi Thapa
	 */
	public class CloseButton extends MovieClip {
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : Sprite;
		private var icon : DisplayObject;
		private var _width : Number = 15;
		private var _height : Number = 15;

		public function CloseButton(controller : IController) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			buttonMode = true;
			mouseChildren = false;
			createChidren();
			draw();
			setStyle();
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
		}

		public function dispose() : void {
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			disposeChildren();
			colorScheme = null;
			controller = null;
		}

		private function overHandler(e : MouseEvent) : void {
			icon.transform.colorTransform = colorScheme.highlightCT;
		}

		private function outHandler(e : MouseEvent) : void {
			icon.transform.colorTransform = colorScheme.primaryCT;
		}

		private function createChidren() : void {
			bg = new Sprite();
			addChild(bg);

			var Texture : Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.CloseIcon);
			var rect : Rectangle = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.CloseIcon);
			icon = new Texture();
			icon.width = rect.width;
			icon.height = rect.height;

			addChild(icon);
			centerDisplayObject(icon);
		}

		private function disposeChildren() : void {
			// icon.bitmapData.dispose();
		}

		private function draw() : void {
			bg.graphics.clear();
			bg.graphics.beginFill(0xff0000, 1);
			bg.graphics.drawRect(0, 0, _width, _height);
			bg.graphics.endFill();
		}

		private function setStyle() : void {
			icon.transform.colorTransform = colorScheme.primaryCT;
			bg.alpha = 0;
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.floor(this.width / 2 - target.width / 2) ;
			target.y = Math.floor(this.height / 2 - target.height / 2);
		}
	}
}
