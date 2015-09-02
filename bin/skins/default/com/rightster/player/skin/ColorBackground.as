package com.rightster.player.skin {
	import flash.geom.ColorTransform;
	import flash.display.Sprite;

	/**
	 * @author KJR
	 */
	public class ColorBackground extends Sprite {
		private static const DEFAULT_HIGHLIGHT : Number = 0x727272;
		private static const DEFAULT_SHADOW : Number = 0x000000;
		private static const DEFAULT_HIGHLIGHT_WIDTH : Number = 1;
		private static const DEFAULT_SHADOW_WIDTH : Number = 2;
		private static const DEFAULT_HEIGHT : Number = 24;
		private var baseCT : ColorTransform;
		private var baseAlpha : Number;
		private var highlight : Number;
		private var shadow : Number;
		private var bgAsset : Sprite;
		private var highlightAsset : Sprite;
		private var shadowAsset : Sprite;
		private var shouldDisplayHighlight : Boolean;
		private var shouldDisplayShadow : Boolean;
		private var _width : Number = 5;
		private var _height : Number = 0;

		override public function get width() : Number {
			return _width;
		}

		override public function set width(w : Number) : void {
			_width = w;
			draw();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(h : Number) : void {
			_height = h;
			draw();
		}

		public function ColorBackground(baseCT : ColorTransform, baseAlpha : Number = 1, shouldDisplayHighlight : Boolean = true, shouldDisplayShadow : Boolean = true, highlight : Number = DEFAULT_HIGHLIGHT, shadow : Number = DEFAULT_SHADOW) {
			this._height = DEFAULT_HEIGHT;
			this.shouldDisplayHighlight = shouldDisplayHighlight;
			this.shouldDisplayShadow = shouldDisplayShadow;
			this.baseCT = baseCT;
			this.baseAlpha = baseAlpha;
			this.highlight = highlight;
			this.shadow = shadow;

			createChildren();
			draw();
		}

		public function setColorTansform(value : ColorTransform) : void {
			this.baseCT = value;
			draw();
		}

		private function createChildren() : void {
			bgAsset = new Sprite();
			highlightAsset = new Sprite();
			shadowAsset = new Sprite();

			addChild(this.bgAsset);
			addChild(this.highlightAsset);
			addChild(this.shadowAsset);
		}

		private function removeAllChildren() : void {
			removeChild(this.bgAsset);
			removeChild(this.highlightAsset);
			removeChild(this.shadowAsset);
		}

		private function draw() : void {
			bgAsset.graphics.clear();
			bgAsset.graphics.beginFill(0xff0000);
			bgAsset.graphics.drawRect(0, 0, _width, _height);
			bgAsset.graphics.endFill();
			bgAsset.transform.colorTransform = this.baseCT;

			if (shouldDisplayHighlight) {
				highlightAsset.graphics.clear();
				highlightAsset.graphics.beginFill(this.highlight);
				highlightAsset.graphics.drawRect(0, 0, DEFAULT_HIGHLIGHT_WIDTH, _height);
				highlightAsset.graphics.endFill();
			}

			if (shouldDisplayShadow) {
				shadowAsset.graphics.clear();
				shadowAsset.graphics.beginFill(this.shadow);
				shadowAsset.graphics.drawRect(_width - DEFAULT_SHADOW_WIDTH, 0, DEFAULT_SHADOW_WIDTH, _height);
				shadowAsset.graphics.endFill();
			}
		}

		public function dispose() : void {
			bgAsset.graphics.clear();
			highlightAsset.graphics.clear();
			shadowAsset.graphics.clear();

			removeAllChildren();

			baseCT = null;
			bgAsset = null;
			highlightAsset = null;
			shadowAsset = null;
		}
	}
}
