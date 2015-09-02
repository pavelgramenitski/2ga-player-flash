package com.rightster.player.skin {
	import com.rightster.player.view.IColors;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author KJR
	 */
	public class Tooltip extends Sprite {
		private const TEXTFIELD_HEIGHT : Number = 17;
		private static const PADDING : Number = 2;
		private var bg : Sprite;
		private var tf : TextField;
		private var autoSize : Boolean = true;
		private var _width : Number = 39;
		private var _height : Number = 18;
		private var _colorScheme : IColors;

		public function Tooltip() : void {
			createChildren();
			draw();
			layout();
		}

		/*
		 * PUBLIC METHODS
		 */
		public function dispose() : void {
		}

		public function setDisplay(value : String) : void {
			tf.htmlText = value;
			tf.autoSize = TextFieldAutoSize.CENTER;

			if (autoSize) {
				this.width = tf.textWidth + (PADDING * 2);
				this.height = tf.textHeight;
			}
		}

		/*
		 * GETTERS/SETTERS
		 */
		override public function get width() : Number {
			return _width;
		}

		override public function set width(n : Number) : void {
			_width = n;
			draw();
			layout();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(n : Number) : void {
			_height = n;
			draw();
			layout();
		}

		public function get colorScheme() : IColors {
			return _colorScheme;
		}

		public function set colorScheme(value : IColors) : void {
			_colorScheme = value;
			commitProperties();
		}

		/*
		 * PRIVATE METHODS
		 */
		private function createChildren() : void {
			bg = new Sprite();
			addChild(bg);

			var tFormat : TextFormat = new TextFormat();
			tFormat.font = Constants.FONT_NAME;
			tFormat.size = Constants.FONT_SIZE_NORMAL;
			tFormat.align = TextFormatAlign.CENTER;
			tFormat.color = 0x000000;
			tf = new TextField();
			tf.defaultTextFormat = tFormat;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.embedFonts = false;
			tf.selectable = false;
			tf.height = TEXTFIELD_HEIGHT;
			tf.width = this.width;
			tf.autoSize = TextFieldAutoSize.CENTER;
			addChild(tf);
		}

		private function draw() : void {
			with (bg.graphics) {
				clear();
				beginFill(0xff0000, 1);
				drawRect(0, 0, this.width, this.height);
				endFill();
			}
		}

		private function layout() : void {
			tf.x = Math.round(this.width / 2 - tf.width / 2);
			tf.y = Math.round(this.height / 2 - tf.height / 2);
		}

		private function commitProperties() : void {
			tf.alpha = colorScheme.baseAlpha;
			bg.transform.colorTransform = colorScheme.primaryCT;
		}
	}
}
