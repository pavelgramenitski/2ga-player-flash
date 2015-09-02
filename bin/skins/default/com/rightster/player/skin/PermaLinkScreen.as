package com.rightster.player.skin {
	import flash.system.System;
	import flash.events.MouseEvent;
	import flash.text.TextField;

	import com.rightster.player.controller.IController;

	import flash.display.MovieClip;

	/**
	 * @author Ravi Thapa
	 */
	public class PermaLinkScreen extends MovieClip {
		private static const TEXT_URL : String = "txt_url";
		private const CLOSE_BTN_X : Number = 197;
		private const CLOSE_BTN_Y : Number = 11;
		private const COPY_BTN_X : Number = 168;
		private const COPY_BTN_Y : Number = 73;
		private var controller : IController;
		private var closeButton : CloseButton;
		private var copyButton : CopyButton;
		private var tf : TextField;

		public function PermaLinkScreen(controller : IController) {
			this.controller = controller;

			closeButton = new CloseButton(controller);
			addChild(closeButton);
			closeButton.x = CLOSE_BTN_X;
			closeButton.y = CLOSE_BTN_Y;

			copyButton = new CopyButton(controller);
			addChild(copyButton);
			copyButton.x = COPY_BTN_X;
			copyButton.y = COPY_BTN_Y;

			tf = this[TEXT_URL];
			tf.text = controller.video.readMoreUrl || "";

			closeButton.addEventListener(MouseEvent.CLICK, clickHandlerClose);
			copyButton.addEventListener(MouseEvent.CLICK, clickHandlerCopy);
		}

		private function clickHandlerClose(evt : MouseEvent) : void {
			this.visible = false;
		}

		private function clickHandlerCopy(evt : MouseEvent) : void {
			System.setClipboard(String(controller.video.readMoreUrl));
		}

		public function dispose() : void {
			removeEventListener(MouseEvent.CLICK, clickHandlerClose);
			removeEventListener(MouseEvent.CLICK, clickHandlerCopy);
			removeChild(closeButton);
			removeChild(copyButton);
			closeButton = null;
			copyButton = null;
			controller = null;
		}
	}
}
