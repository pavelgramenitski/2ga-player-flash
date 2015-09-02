package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.model.MetaQuality;
	import com.rightster.player.view.IColors;

	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author Daniel
	 */
	public class QualityButton extends Sprite {
	
		private const TEXTFIELD_HEIGHT : Number = 18;
		private var controller : IController;
		private var colorScheme : IColors;
		private var quality : String;
		private var bg : ColorBackground;
		private var tf : TextField;
		private var selected : Boolean;
		private var _width : Number = 44;
		private var _height : Number = 31;

		public function QualityButton(controller : IController, quality : *) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			mouseChildren = false;
			buttonMode = true;
			createChildren();

			if (quality is String) {
				this.quality = quality;
				tf.text = quality;
			} else {
				var vo : MetaQuality = (quality as MetaQuality);
				this.quality = vo.quality;
				tf.text = vo.label;
			}

			setInitialDisplayState();
			registerEventHandlers();
			playbackQualityEventHandler();
		}

		public function dispose() : void {
			unregisterEventHandlers();
			disposeChildren();
			bg = null;
			tf = null;
			quality = null;
			colorScheme = null;
			controller = null;
		}

		override public function get width() : Number {
			return _width;
		}

		override public function get height() : Number {
			return _height;
		}

		private function playbackQualityEventHandler(e : PlaybackQualityEvent = null) : void {
			if (quality == controller.getPlaybackQuality()) {
				selected = true;
				useHandCursor = false;
				bg.transform.colorTransform = colorScheme.selectedCT;
				bg.alpha = colorScheme.highlightAlpha;
			} else {
				selected = false;
				useHandCursor = true;
				bg.transform.colorTransform = colorScheme.baseCT;
				bg.alpha = colorScheme.baseAlpha;
			}
		}

		private function clickHandler(e : MouseEvent) : void {
			if (!selected) {
				controller.setPlaybackQuality(quality);
			}
		}

		private function overHandler(e : MouseEvent) : void {
			if (!selected) {
				bg.transform.colorTransform = colorScheme.highlightCT;
				bg.alpha = colorScheme.highlightAlpha;
			}
		}

		private function outHandler(e : MouseEvent) : void {
			if (!selected) {
				bg.transform.colorTransform = colorScheme.baseCT;
				bg.alpha = colorScheme.baseAlpha;
			}
		}

		private function setInitialDisplayState() : void {
			centerTextField();
			setStyle();
		}

		private function centerTextField() : void {
			tf.x = Math.round(this.width / 2 - tf.width / 2);
			tf.y = Math.round(this.height / 2 - tf.height / 2);
		}

		private function setStyle() : void {
			tf.transform.colorTransform = colorScheme.primaryCT;
			bg.transform.colorTransform = colorScheme.baseCT;
			bg.alpha = colorScheme.baseAlpha;
		}

		private function registerEventHandlers() : void {
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			addEventListener(MouseEvent.CLICK, clickHandler);
			controller.addEventListener(PlaybackQualityEvent.CHANGE, playbackQualityEventHandler);
		}

		private function unregisterEventHandlers() : void {
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			removeEventListener(MouseEvent.CLICK, clickHandler);
			controller.removeEventListener(PlaybackQualityEvent.CHANGE, playbackQualityEventHandler);
		}

		private function createChildren() : void {
			bg = new ColorBackground(colorScheme.baseCT, colorScheme.baseAlpha, false, false, 0);
			addChild(bg);
			bg.width = this.width;
			bg.height = this.height;

			var tFormat : TextFormat = new TextFormat();
			tFormat.font = Constants.FONT_NAME;
			tFormat.size = Constants.FONT_SIZE_NORMAL;
			tFormat.align = TextFormatAlign.CENTER;
			tf = new TextField();
			tf.defaultTextFormat = tFormat;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.embedFonts = false;
			tf.selectable = false;
			tf.height = TEXTFIELD_HEIGHT;
			tf.width = this.width;

			addChild(tf);
			centerTextField();
		}

		private function disposeChildren() : void {
			bg.dispose();
		}
	}
}
