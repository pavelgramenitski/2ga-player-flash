package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author KJR
	 */
	public class PlayAllButton extends Sprite {
		private const TEXTFIELD_HEIGHT : Number = 18;
		private  const LABEL_TEXT : String = "Play All";
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : DisplayObject;
		private var tf : TextField;
		private var _enabled : Boolean;
		private var _width : Number = 66;
		private var _height : Number = 24;
		private var _padding : Number = 7;

		override public function set width(w : Number) : void {
			_width = w;
			layout();
		}

		override public function set height(h : Number) : void {
			_height = h;
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

		public function PlayAllButton(controller : IController) {
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
			tf = null;
			controller = null;
		}

		private function createChildren() : void {
			var Texture : Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlayAllButtonBackground);
			var rect : Rectangle = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlayAllButtonBackground);
			bg = new Texture();
			bg.width = rect.width;
			bg.height = rect.height;

			addChild(bg);

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

			addChild(tf);
		}

		private function setInitialDisplayState() : void {
			layout();
			tf.text = LABEL_TEXT;
			tf.autoSize = TextFieldAutoSize.LEFT;
			enableButton();
			setStyle();
		}

		private function setStyle() : void {
			bg.transform.colorTransform = colorScheme.baseCT;
			// bg.alpha = colorScheme.baseAlpha;
			tf.transform.colorTransform = colorScheme.primaryCT;
		}

		private function layout() : void {
			tf.x = _padding;
			tf.y = Math.round(_height / 2 - tf.height / 2);
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
				controller.playVideoAt(0);
			}
		}

		private function overHandler(e : MouseEvent) : void {
			if (_enabled) {
				bg.transform.colorTransform = colorScheme.highlightCT;
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
