package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.text.TextFormatAlign;

	/**
	 * @author KJR
	 */
	public class PlaylistBarViewControl extends Sprite {
		private static const DEFAULT_WIDTH : Number = 136;
		private static const DEFAULT_HEIGHT : Number = 24;
		private static const PADDING_LEFT : Number = 18;
		private static const PADDING_RIGHT : Number = 18;
		private static const HORIZONTAL_SPACING : Number = 12;
		private const TEXTFIELD_WIDTH : Number = 90;
		private const TEXTFIELD_HEIGHT : Number = 18;
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : ColorBackground;
		private var icon : DisplayObject;
		private var tf : TextField;
		private var strDisplay : String = "";
		private var _height : Number;
		private var _width : Number = 0;
		private var _selected : Boolean = false;

		// private var _enabled : Boolean = true;
		public function PlaylistBarViewControl(controller : IController) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			mouseChildren = false;
			buttonMode = true;
			_height = DEFAULT_HEIGHT;
			_width = DEFAULT_WIDTH;
			createChildren();
			layout();
			setStyle();
			registerEventListeners();
		}

		/*
		 * PUBLIC METHODS
		 */
		public function dispose() : void {
			unregisterEventListeners();
			removeAllChildren();
			colorScheme = null;
			bg = null;
			icon = null;
			tf = null;
			controller = null;
		}

		public function set displayText(value : String) : void {
			strDisplay = value;
			tf.text = strDisplay;
		}

		/*
		 * GETTERS/ SETTERS
		 */
		override public function get width() : Number {
			return _width;
		}

		override public function set width(w : Number) : void {
			_width = w;
			layout();
		}

		public function get selected() : Boolean {
			return _selected;
		}

		public function set selected(value : Boolean) : void {
			_selected = value;
			// _enabled = !_selected;
			setDisplayState();
		}

		/*
		 * EVENT HANDLERS
		 */
		private function playlistEventHandler(event : PlaylistViewEvent) : void {
			this.selected = (event.type == PlaylistViewEvent.SHOW ) ? true : false;
		}

		private function clickHandler(e : MouseEvent) : void {
			outHandler();
			if (!_selected) {
				controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.SHOW));
			} else {
				controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.HIDE));
			}
		}

		private function overHandler(e : MouseEvent) : void {
			if (!_selected) {
				bg.setColorTansform(colorScheme.highlightCT) ;
			}
		}

		private function outHandler(e : MouseEvent = null) : void {
			if (!_selected) {
				bg.setColorTansform(colorScheme.baseCT) ;
			}
		}

		public function pluginEventHandler(event : PluginEvent) : void {
			layout();
			selected = false;
		}

		/*
		 * PRIVATE METHODS
		 */
		private function createChildren() : void {
			bg = new ColorBackground(colorScheme.baseCT, colorScheme.baseAlpha, false, true);
			addChild(bg);
			bg.width = this._width;

			var Texture:Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.PlaylistIcon);
			var rect:Rectangle =  TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.PlaylistIcon);
			icon = new Texture();
			icon.width = rect.width;
			icon.height = rect.height;
			addChild(icon);
		
			var tFormat : TextFormat = new TextFormat();
			tFormat.font = Constants.FONT_NAME;
			tFormat.size = Constants.FONT_SIZE_NORMAL;
			tFormat.align = TextFormatAlign.LEFT;
			tFormat.leading = 0;
			tf = new TextField();
			tf.defaultTextFormat = tFormat;
			tf.multiline = false;
			tf.wordWrap = false;
			tf.embedFonts = false;
			tf.selectable = false;
			tf.height = TEXTFIELD_HEIGHT;
			tf.width = TEXTFIELD_WIDTH;

			addChild(tf);
		}

		private function removeAllChildren() : void {
			removeChildren(0, numChildren - 1);
		}

		private function setStyle() : void {
			icon.transform.colorTransform = colorScheme.primaryCT;
			tf.transform.colorTransform = colorScheme.primaryCT;
		}

		private function layout() : void {
			bg.width = _width;
			bg.height = _height;

			icon.x = PADDING_LEFT;
			icon.y = Math.round(_height / 2 - icon.height / 2);

			tf.x = Math.round(icon.x + icon.width + HORIZONTAL_SPACING);
			tf.y = Math.round(_height / 2 - tf.height / 2);

			var maxWidth : Number = _width - PADDING_RIGHT - tf.x;

			if (tf.textWidth > maxWidth) {
				var avg : Number = Number(tf.textWidth / tf.length);
				var finalAvg : Number = Math.floor(maxWidth / avg);
				tf.text = strDisplay.substring(0, finalAvg);
			}
		}

		private function setDisplayState() : void {
			var ct : ColorTransform = !selected ? colorScheme.baseCT : colorScheme.selectedCT;
			buttonMode = true;
			bg.setColorTansform(ct) ;
		}

		private function registerEventListeners() : void {
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.addEventListener(PlaylistViewEvent.SHOW, playlistEventHandler);
			controller.addEventListener(PlaylistViewEvent.HIDE, playlistEventHandler);
			controller.addEventListener(PluginEvent.REFRESH, pluginEventHandler);
		}

		private function unregisterEventListeners() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.removeEventListener(PlaylistViewEvent.SHOW, playlistEventHandler);
			controller.removeEventListener(PlaylistViewEvent.HIDE, playlistEventHandler);
			controller.removeEventListener(PluginEvent.REFRESH, pluginEventHandler);
		}
	}
}
