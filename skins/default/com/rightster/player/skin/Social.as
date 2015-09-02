package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author KJR
	 */
	public class Social extends MovieClip {
		private static const SOCIAL_BUTTON_X : Number = 0;
		private static const SOCIAL_BUTTON_PADDING : Number = 0;
		private static const WIDTH : Number = 44;
		private var controller : IController;
		private var colorScheme : IColors;
		private var icon : DisplayObject;
		private var bg : Sprite;
		private var buttonContainer : Sprite;
		private var socialList : Array;
		private var socialButtons : Array;
		private var _visible : Boolean = true;
		private var _enabled : Boolean = false;
		private var _width : Number = 44;
		private var _height : Number = 31;

		public function Social(controller : IController, list : Array) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			this.socialList = list;
			createChildren();
			draw();
			setInitialDisplayState();
			registerEventListeners();
		}

		public function dispose() : void {
			disposeSocialButtons();
			disposeChildren();
			unregisterEventListeners();
			socialList = null;
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
			return _width;
		}

		override public function get height() : Number {
			return _height;
		}

		override public function get enabled() : Boolean {
			return _enabled;
		}

		override public function set enabled(value : Boolean) : void {
			_enabled = value;
			_enabled ? enableButton() : disableButton();
		}

		private function playerStateEventHandler(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					_enabled = true;
					layoutChildren();
					break;
				case PlayerState.VIDEO_STARTED :
					_enabled = true;
					layoutChildren();
					break;
				case PlayerState.AD_STARTED :
					_enabled = false;
					layoutChildren();
					toggleVisibility();
					break;
			}
		}

		private function pluginEventHandler(event : PluginEvent) : void {
			enabled = false;
			layoutChildren();
		}

		private function overHandler(e : MouseEvent) : void {
			if (mouseHandlersEnabled()) {
				buttonContainer.visible = true;
				bg.alpha = 1;
				bg.transform.colorTransform = colorScheme.backgroundCT;
			}
		}

		private function outHandler(e : MouseEvent) : void {
			if (mouseHandlersEnabled()) {
				buttonContainer.visible = false;
				bg.alpha = 0;
			}
		}

		private function enableButton() : void {
			buttonMode = true;
		}

		private function disableButton() : void {
			buttonMode = false;
			bg.alpha = 0;
		}

		private function mouseHandlersEnabled() : Boolean {
			for (var item : String in socialButtons) {
				var button : ISocialButton = (socialButtons[item] as ISocialButton);
				if (button.sharingIsValid()) {
					return true;
				}
			}

			return false;
		}

		private function createChildren() : void {
			// button background
			bg = new Sprite();
			addChild(bg);

			var Texture : Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.SocialIcon);
			var rect : Rectangle = TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.SocialIcon);
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
			// icon.bitmapData.dispose();
		}

		private function draw() : void {
			with(bg) {
				graphics.clear();
				graphics.beginFill(0xff0000, 1);
				graphics.drawRect(0, 0, this.width, this.height);
				graphics.endFill();
			}
		}

		private function setInitialDisplayState() : void {
			bg.alpha = 0;
			buttonMode = true;
			buttonContainer.visible = false;
			setStyle();
			toggleVisibility();
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

		private function addSocialButtons() : void {
			socialButtons = [];

			for (var i : int = 0; i < socialList.length; i++) {
				if ((socialList[i] as ISocialButton).sharingIsValid()) {
					buttonContainer.addChild((socialList[i] as Sprite));
					socialButtons.push((socialList[i] as Sprite));
				}
			}
		}

		private function layoutSocialButtons() : void {
			var previousYpos : Number = 0;
			if (socialButtons) {
				for (var i : int = 0; i < socialButtons.length; i++) {
					var button : Sprite = socialButtons[i] as Sprite;
					button.y = previousYpos - button.height - SOCIAL_BUTTON_PADDING;
					button.x = SOCIAL_BUTTON_X;
					previousYpos = button.y;
				}
			}
		}

		private function removeSocialButtons() : void {
			if (socialButtons) {
				for (var i : int = socialButtons.length - 1; i >= 0; i--) {
					var button : Sprite = socialButtons.pop() as Sprite;
					buttonContainer.removeChild(button);
				}
			}
		}

		private function disposeSocialButtons() : void {
			if (socialButtons) {
				for (var i : int = socialButtons.length - 1; i >= 0; i--) {
					var button : Sprite = socialButtons.pop() as Sprite;
					buttonContainer.removeChild(button);
					(button as ISocialButton).dispose();
				}
			}

			socialButtons = null;
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
			bg.alpha = colorScheme.baseAlpha;
		}

		private function layoutChildren() : void {
			if (socialList == null || socialList.length < 2) {
				enabled = false;
				toggleVisibility();
				return;
			}
			removeSocialButtons();
			addSocialButtons();
			layoutSocialButtons();
			enabled = (socialButtons.length > 0) ? true : false;
			// buttonMode = mouseHandlersEnabled();
			toggleVisibility();
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.floor(this.width / 2 - target.width / 2) ;
			target.y = Math.floor(this.height / 2 - target.height / 2);
		}
	}
}
