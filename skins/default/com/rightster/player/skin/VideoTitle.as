package com.rightster.player.skin {
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.controller.IController;
	import com.rightster.player.view.IColors;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author Ravi Thapa
	 */
	public class VideoTitle extends Sprite {
		private static const TEXT_TITLE_PADDING : Number = 17;
		private const TEXTFIELD_HEIGHT : Number = 18;
		private const TEXTFIELD_XPOS : Number = 16;
		private const TEXTFIELD_YPOS : Number = 3;
		private static const ELLIPSIS : String = "\u2026";
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : Sprite;
		private var tf : TextField;
		private var strTitle : String = "";
		private var _width : Number = 0;
		private var _height : Number = 24;

		override public function set width(w : Number) : void {
			_width = w;
			draw();
			layout();
		}

		public function VideoTitle(controller : IController) {
			this.controller = controller;
			this.colorScheme = this.controller.colors;
			this.strTitle = controller.video.title;

			bg = new Sprite();
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
			tf.x = TEXTFIELD_XPOS;
			tf.y = TEXTFIELD_YPOS;
			tf.height = TEXTFIELD_HEIGHT;
			tf.width = this.width;
			addChild(tf);

			tf.text = strTitle;
			tf.autoSize = TextFieldAutoSize.LEFT;

			setInitialDisplayState();
			
			registerEventListeners();
		}
		
		private function handlePluginRefreshEvent(event : PluginEvent) : void {
			strTitle = controller.video.title;
			layout();
		}

		private function setInitialDisplayState() : void {
			draw();
			layout();
			setStyle();
		}

		private function setStyle() : void {
			bg.transform.colorTransform = colorScheme.baseCT;
			tf.transform.colorTransform = colorScheme.primaryCT;
		}

		private function draw() : void {
			bg.graphics.clear();
			bg.graphics.beginFill(0xff0000, 1);
			bg.graphics.drawRect(0, 0, _width, _height);
			bg.graphics.endFill();
		}

		private function layout() : void {
			var maxWidth : Number = _width - (TEXT_TITLE_PADDING * 2);
			tf.text = strTitle;
			if (tf.textWidth > maxWidth) {
				var avg : Number = Number(tf.textWidth / strTitle.length);
				var finalAvg : Number = Number(maxWidth / avg);
				tf.text = strTitle.substring(0, finalAvg);
			}

			tf.autoSize = TextFieldAutoSize.LEFT;
			
			assertTextFieldMaxWidth();
		}
		
		
		private function assertTextFieldMaxWidth() : void {
			var maxWidth : Number = _width - (TEXT_TITLE_PADDING * 2);
			tf.text = strTitle;

			if (tf.textWidth > maxWidth) {
				var avg : Number = Number(tf.textWidth / tf.length);
				var finalAvg : Number = Number(maxWidth / avg);
				tf.text = strTitle.substring(0, finalAvg - 3) + ELLIPSIS;
			}

			tf.autoSize = TextFieldAutoSize.LEFT;
		}
		
		private function registerEventListeners() : void {
			controller.addEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}

		private function unregisterEventListeners() : void {
			controller.removeEventListener(PluginEvent.REFRESH, handlePluginRefreshEvent);
		}
		
		public function dispose() : void {
			removeChildren(0, numChildren - 1);
			unregisterEventListeners();
			colorScheme = null;
			controller = null;
		}
	}
}
