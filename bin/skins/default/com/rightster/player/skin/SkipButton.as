package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author KJR
	 */
	public class SkipButton extends Sprite {
		private static const LABEL_TEXT : String = "Skip";
		private const TEXTFIELD_HEIGHT : Number = 18;
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : Sprite;
		private var icon : DisplayObject;
		private var tf : TextField;
		private var _enabled : Boolean;
		private var _width : Number = 73;
		private var _height : Number = 24;
		private var _padding : Number = 15;

		override public function set width(w : Number) : void {
			_width = w;
			draw();
			layout();
		}

		override public function set height(h : Number) : void {
			_height = h;
			draw();
			layout();
		}

		public function get padding() : Number {
			return _padding;
		}

		public function set padding(value : Number) : void {
			_padding = value;
		}

		public function get enabled() : Boolean {
			return _enabled;
		}

		public function set enabled(value : Boolean) : void {
			_enabled = value;
			_enabled ? enableButton() : disableButton();
		}

		public function SkipButton(controller : IController) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			buttonMode = true;
			mouseChildren = false;
			_enabled = true;

			createChildren();
			registerEventListeners();
			setInitialDisplayState();
		}

		public function dispose() : void {
			unregisterEventListeners();
			removeChildren(0, numChildren - 1);
			colorScheme = null;
			bg = null;
			icon = null;
			controller = null;
		}

		private function setInitialDisplayState() : void {
			draw();
			layout();
			enableButton();
			setStyle();
		}

		private function setStyle() : void {
			icon.transform.colorTransform = colorScheme.primaryCT;
			tf.transform.colorTransform = colorScheme.primaryCT;
		}

		private function draw() : void {
			bg.graphics.clear();
			bg.graphics.beginFill(0xff0000, 1);
			bg.graphics.drawRect(0, 0, _width, _height);
			bg.graphics.endFill();
		}

		private function layout() : void {
			tf.x = _padding;
			tf.y = Math.round(_height / 2 - tf.height / 2);
			tf.width = this.width - (_padding * 2);
			icon.x = Math.round(_width - icon.width - _padding);
			icon.y = Math.round(_height / 2 - icon.height / 2);
		}

		private function createChildren() : void {
			bg = new Sprite();
			addChild(bg);

			var Texture : Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.SkipIcon);
			var rect : Rectangle = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.SkipIcon);
			icon = new Texture();
			icon.width = rect.width;
			icon.height = rect.height;
			addChild(icon);

			var tFormat : TextFormat = new TextFormat();
			tFormat.font = Constants.FONT_NAME;
			tFormat.size = Constants.FONT_SIZE_NORMAL;
			tFormat.align = TextFormatAlign.LEFT;
			tf = new TextField();
			tf.defaultTextFormat = tFormat;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.embedFonts = false;
			tf.selectable = false;
			tf.height = TEXTFIELD_HEIGHT;
			tf.width = this.width;
			tf.text = LABEL_TEXT;
			addChild(tf);
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
			bg.transform.colorTransform = colorScheme.baseCT;
		}

		private function disableButton() : void {
			buttonMode = false;
			bg.transform.colorTransform = colorScheme.inactiveCT;
		}

		private function clickHandler(e : MouseEvent) : void {
			if (_enabled) {
				outHandler();
				controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_STOP));
			}
		}

		private function overHandler(e : MouseEvent) : void {
			if (_enabled) {
				bg.transform.colorTransform = colorScheme.advertCT;
			}
		}

		private function outHandler(e : MouseEvent = null) : void {
			if (_enabled) {
				bg.transform.colorTransform = colorScheme.baseCT;
			}
		}

		private function exitFullscreen(e : ResizeEvent) : void {
			if (_enabled) {
				outHandler();
			}
		}
	}
}
