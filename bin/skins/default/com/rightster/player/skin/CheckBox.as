package com.rightster.player.skin {
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author KJR
	 */
	public class CheckBox extends Sprite {
		private var bg : Sprite;
		private var icon : DisplayObject;
		private var isSelected : Boolean = true;
		private var colorScheme : IColors;
		private var _width : Number = 17;
		private var _height : Number = 17;

		public function CheckBox(colorScheme : IColors) {
			this.colorScheme = colorScheme;
			mouseChildren = false;
			buttonMode = true;
			createChildren();
			draw();
			setStyle();
			addEventListener(MouseEvent.CLICK, clickHandler);
		}

		public function dispose() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			disposeChildren();
			colorScheme = null;
		}

		public function get selected() : Boolean {
			return isSelected;
		}

		private function clickHandler(e : MouseEvent) : void {
			if (isSelected) {
				icon.visible = isSelected = false;
			} else {
				icon.visible = isSelected = true;
			}
		}

		private function createChildren() : void {
			bg = new Sprite();
			addChild(bg);

			var Texture : Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.TickIcon);
			var rect : Rectangle = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.TickIcon);
			icon = new Texture();
			icon.width = rect.width;
			icon.height = rect.height;

			addChild(icon);
			centerDisplayObject(icon);
		}

		private function disposeChildren() : void {
			icon = null;
		}

		private function draw() : void {
			bg.graphics.clear();
			bg.graphics.beginFill(0xff0000, 1);
			bg.graphics.drawRect(0, 0, _width, _height);
			bg.graphics.endFill();
		}

		private function setStyle() : void {
			bg.transform.colorTransform = colorScheme.baseCT;
			bg.alpha = colorScheme.baseAlpha;
			icon.transform.colorTransform = colorScheme.primaryCT;
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.floor(this.width / 2 - target.width / 2) ;
			target.y = Math.floor(this.height / 2 - target.height / 2);
		}
	}
}
