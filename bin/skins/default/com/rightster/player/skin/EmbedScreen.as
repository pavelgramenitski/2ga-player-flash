package com.rightster.player.skin {
	import com.rightster.player.view.IColors;

	import flash.events.FocusEvent;
	import flash.system.System;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import com.rightster.player.controller.IController;

	import flash.display.MovieClip;

	/**
	 * @author Ravi Thapa
	 */
	public class EmbedScreen extends MovieClip {
		private static const IFRAME_CHECKBOX : String = "iframe_checkbox";
		private static const AUTOPLAY_CHECKBOX : String = "autoplay_checkbox";
		private static const TXT_WIDTH : String = "txt_width";
		private static const TXT_HEIGHT : String = "txt_height";
		private static const TXT_IFRAME : String = "txt_iframe";
		private static const TITLE_LABEL_TEXT : String = "Embed Size";
		private static const IFRAME_LABEL_TEXT : String = "iFrame";
		private static const X_LABEL_TEXT : String = "x";
		private static const PIXELS_LABEL_TEXT : String = "pixels";
		private static const AUTOPLAY_LABEL_TEXT : String = "Autoplay";
		private static const RESTRICT : String = "0-9";
		private static const DEFAULT_WIDTH : String = "640";
		private static const DEFAULT_HEIGHT : String = "360";
		private const CLOSE_BTN_X : Number = 235;
		private const CLOSE_BTN_Y : Number = 11;
		private const COPY_BTN_X : Number = 206;
		private const COPY_BTN_Y : Number = 129;
		private var controller : IController;
		private var colorScheme : IColors;
		private var closeButton : CloseButton;
		private var copyButton : CopyButton;
		private var iframeCheckBox : MovieClip;
		private var autoPlayCheckBox : MovieClip;
		private var txtWidth : TextField;
		private var txtHeight : TextField;
		private var txtIframe : TextField;

		public function EmbedScreen(controller : IController) {
			this.controller = controller;
			this.colorScheme = this.controller.colors;

			closeButton = new CloseButton(controller);
			addChild(closeButton);
			closeButton.x = CLOSE_BTN_X;
			closeButton.y = CLOSE_BTN_Y;

			copyButton = new CopyButton(controller);
			addChild(copyButton);
			copyButton.x = COPY_BTN_X;
			copyButton.y = COPY_BTN_Y;

			iframeCheckBox = this[IFRAME_CHECKBOX];

			autoPlayCheckBox = this[AUTOPLAY_CHECKBOX];

			txtWidth = this[TXT_WIDTH];
			txtHeight = this[TXT_HEIGHT];
			txtIframe = this[TXT_IFRAME];

			txtWidth.restrict = RESTRICT;
			txtHeight.restrict = RESTRICT;

			registerEventListeners();
		}

		private function textWidthFocusInFunc(evt : FocusEvent) : void {
			(evt.currentTarget as TextField).text = "";
		}

		private function textWidthFocusOutFunc(evt : FocusEvent) : void {
			if ((evt.currentTarget as TextField).name == TXT_WIDTH && (evt.currentTarget as TextField).text == "") (evt.currentTarget as TextField).text = DEFAULT_WIDTH;
			if ((evt.currentTarget as TextField).name == TXT_HEIGHT && (evt.currentTarget as TextField).text == "") (evt.currentTarget as TextField).text = DEFAULT_HEIGHT;
		}

		private function clickHandlerClose(evt : MouseEvent) : void {
			if (this.visible) this.visible = false;
		}

		private function clickHandlerCopy(evt : MouseEvent) : void {
			System.setClipboard(String(controller.video.readMoreUrl));
		}

		public function dispose() : void {
			unregisterEventListeners();

			removeChild(closeButton);
			removeChild(copyButton);
			closeButton = null;
			copyButton = null;
			controller = null;
		}

		private function registerEventListeners() : void {
			closeButton.addEventListener(MouseEvent.CLICK, clickHandlerClose);
			copyButton.addEventListener(MouseEvent.CLICK, clickHandlerCopy);

			txtWidth.addEventListener(FocusEvent.FOCUS_IN, textWidthFocusInFunc);
			txtHeight.addEventListener(FocusEvent.FOCUS_IN, textWidthFocusInFunc);

			txtWidth.addEventListener(FocusEvent.FOCUS_OUT, textWidthFocusOutFunc);
			txtHeight.addEventListener(FocusEvent.FOCUS_OUT, textWidthFocusOutFunc);
		}

		private function unregisterEventListeners() : void {
			closeButton.removeEventListener(MouseEvent.CLICK, clickHandlerClose);
			copyButton.removeEventListener(MouseEvent.CLICK, clickHandlerCopy);

			txtWidth.removeEventListener(FocusEvent.FOCUS_IN, textWidthFocusInFunc);
			txtHeight.removeEventListener(FocusEvent.FOCUS_IN, textWidthFocusInFunc);

			txtWidth.removeEventListener(FocusEvent.FOCUS_OUT, textWidthFocusOutFunc);
			txtHeight.removeEventListener(FocusEvent.FOCUS_OUT, textWidthFocusOutFunc);
		}
	}
}
