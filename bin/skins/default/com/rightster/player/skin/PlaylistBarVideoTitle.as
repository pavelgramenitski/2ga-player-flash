package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.view.IColors;

	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author KJR
	 */
	public class PlaylistBarVideoTitle extends Sprite {
		private static const TEXT_TITLE_PADDING : Number = 36;
		private const TEXTFIELD_WIDTH : Number = 100;
		private const TEXTFIELD_HEIGHT : Number = 18;
		private static const PADDING: Number = 12;
		private static const DEFAULT_HEIGHT : Number = 24;
		private static const DEFAULT_WIDTH : Number = 625;
		private static const ELLIPSIS : String = "\u2026";
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : ColorBackground;
		private var tf : TextField;
		private var previous : PlaylistBarNavigationButton;
		private var next : PlaylistBarNavigationButton;
		private var strTitle : String = "";
		private var _width : Number = 0;

		override public function set width(w : Number) : void {
			_width = w;
			layout();
		}

		public function PlaylistBarVideoTitle(controller : IController) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			_width = DEFAULT_WIDTH;
			strTitle = controller.video.title;

			createChildren();
			assertIndices();
			layout();
			registerEventListeners();
		}

		private function handlePluginRefreshEvent(event : PluginEvent) : void {
			strTitle = controller.video.title;
			layout();
		}

		private function createChildren() : void {
			bg = new ColorBackground(colorScheme.baseCT, colorScheme.baseAlpha);
			addChild(bg);
			bg.width = this._width;

			previous = new PlaylistBarNavigationButton(controller, -1);
			addChild(previous);

			next = new PlaylistBarNavigationButton(controller, 1);
			addChild(next);
			next.scaleX = -1;

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
			tf.width = TEXTFIELD_WIDTH;

			addChild(tf);

			tf.transform.colorTransform = colorScheme.primaryCT;
		}

		private function assertIndices() : void {
			setChildIndex(previous, numChildren - 1);
			setChildIndex(next, numChildren - 1);
			setChildIndex(tf, numChildren - 1);
		}

		private function layout() : void {
			bg.width = this._width;

			previous.x = PADDING;
			previous.y = Math.round(DEFAULT_HEIGHT / 2 - previous.height / 2);

			// next is flipped so we don't need to scope its width;
			next.x = _width - PADDING;
			next.y = Math.round(DEFAULT_HEIGHT / 2 - next.height / 2);

			tf.x = TEXT_TITLE_PADDING;
			tf.y = Math.round(height / 2 - tf.height / 2);

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
			previous.dispose();
			next.dispose();
			unregisterEventListeners();
			colorScheme = null;
			previous = null;
			next = null;
			controller = null;
		}
	}
}
