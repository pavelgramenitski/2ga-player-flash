package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.platform.Platforms;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;

	/**
	 * @author KJR
	 */
	public class Quality extends Sprite {
		private static const CHILD_BUTTON_X : Number = 0;
		private static const CHILD_BUTTON_Y : Number = 0;
		private static const CHILD_BUTTON_PADDING : Number = 0;
		private static const WIDTH : Number = 44;
		private static const HEIGHT : Number = 31;
		private var controller : IController;
		private var colorScheme : IColors;
		private var icon : DisplayObject;
		private var bg : Sprite;
		private var buttonContainer : Sprite;
		private var buttonRegistry : Dictionary;
		private var levels : Array;
		private var _visible : Boolean = true;
		private var _enabled : Boolean = false;
		private var _width : Number;

		public function Quality(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			buttonRegistry = new Dictionary();
			buttonMode = true;
			createChildren();
			draw();
			buttonContainer.visible = false;
			setStyle();
			toggleVisibility();
			registerEventListeners();
		}

		public function dispose() : void {
			disposeChildren();
			disposeChildButtons();
			unregisterEventListeners();
			buttonRegistry = null;
			colorScheme = null;
			controller = null;
		}

		override public function get visible() : Boolean {
			return super.visible;
		}

		override public function set visible(b : Boolean) : void {
			_visible = b;
			toggleVisibility();
		}

		override public function get width() : Number {
			return WIDTH;
		}

		override public function get height() : Number {
			return HEIGHT;
		}

		private function playerStateEventHandler(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					refresh();
					break;
			}
		}

		private function pluginEventHandler(event : PluginEvent) : void {
			disposeChildButtons();
		}

		private function overHandler(e : MouseEvent) : void {
			buttonContainer.visible = true;
			bg.alpha = 1;
			bg.transform.colorTransform = colorScheme.backgroundCT;
		}

		private function outHandler(e : MouseEvent) : void {
			buttonContainer.visible = false;
			bg.alpha = 0;
		}

		private function refresh() : void {
			if (controller.placement.platform == Platforms.TWOGA) {
				levels = controller.video.metaQualities.slice();
				// reverse to ensure 'highest' at top, and 'auto' at bottom
				levels.reverse();
			} else {
				levels = controller.getAvailableQualityLevels();
			}

			// no available quality levels
			if (levels == null || levels.length < 1) {
				_enabled = false;
				toggleVisibility();
				return;
			}

			createChildButtons();
			buttonContainer.visible = false;

			_enabled = true;
			toggleVisibility();
		}

		private function createChildren() : void {
			// button background
			bg = new Sprite();
			addChild(bg);

			// icon
			var Texture:Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.QualityIcon);
			var rect:Rectangle =  TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.QualityIcon);
			icon = new Texture();
			icon.width = rect.width;
			icon.height = rect.height;
			
			addChild(icon);
			centerDisplayObject(icon);

			// holds all quality buttons and has a background
			buttonContainer = new Sprite();
			addChild(buttonContainer);
		}

		private function disposeChildren() : void {
			//icon.bitmapData.dispose();
		}

		private function draw() : void {
			with(bg) {
				graphics.clear();
				graphics.beginFill(0xff0000, 1);
				graphics.drawRect(0, 0, this.width, this.height);
				graphics.endFill();
			}
		}

		private function toggleVisibility() : void {
			if (_enabled && _visible) {
				super.visible = true;
				_width = WIDTH;
			} else {
				super.visible = false;
				_width = 0;
			}
		}

		private function setStyle() : void {
			icon.transform.colorTransform = colorScheme.primaryCT;
			bg.transform.colorTransform = colorScheme.baseCT;
		}

		private function createChildButtons() : void {
			for (var i : int = 0; i < levels.length; i++) {
				var button : QualityButton = new QualityButton(controller, levels[i]);
				button.y = CHILD_BUTTON_Y - (i + 1) * button.height - (i + 1) * CHILD_BUTTON_PADDING;
				button.x = CHILD_BUTTON_X;
				buttonContainer.addChild(button);
				registerChildButtons(button.name, button);
			}
		}

		private function registerChildButtons(name : String, button : QualityButton) : void {
			if (!buttonRegistry.hasOwnProperty(name)) {
				buttonRegistry[name] = button;
			}
		}

		private function disposeChildButtons() : void {
			for (var key : String in buttonRegistry) {
				var button : QualityButton = buttonRegistry[key] as QualityButton;
				button.dispose();
				button.parent.removeChild(button);
				buttonRegistry[key] = null;
				delete buttonRegistry[key];
			}
		}

		private function registerEventListeners() : void {
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.addEventListener(PluginEvent.REFRESH, pluginEventHandler);
		}

		private function unregisterEventListeners() : void {
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			controller.removeEventListener(PlayerStateEvent.CHANGE, playerStateEventHandler);
			controller.removeEventListener(PluginEvent.REFRESH, pluginEventHandler);
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.floor(this.width / 2 - target.width / 2) ;
			target.y = Math.floor(this.height / 2 - target.height / 2);
		}
	}
}
