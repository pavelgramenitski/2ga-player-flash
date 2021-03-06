﻿package com.rightster.player.skin {
	import flash.geom.Rectangle;
	import flash.display.DisplayObject;
	import flash.display.Bitmap;
	// import com.rightster.player.events.PluginEvent;
	import com.rightster.player.view.IColors;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;

	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author KJR
	 */
	public class ShareFB extends Sprite implements ISocialButton {
		private var controller : IController;
		private var colorScheme : IColors;
		private var icon : DisplayObject;
		private var bg : Sprite;
		private var _visible : Boolean = true;
		private var _enabled : Boolean = false;
		private var _width : Number = 44;
		private var _height : Number = 31;

		public function ShareFB(controller : IController) : void {
			this.controller = controller;
			colorScheme = this.controller.colors;
			buttonMode = true;
			createChildren();
			draw();
			setStyle();
			registerEventListeners();
		}

		public function show() : void {
			if (_enabled && _visible && !controller.video.geoBlocked) {
				super.visible = true;
				this.height = _height;
			}
		}

		public function hide() : void {
			super.visible = false;
			this.height = 0;
		}

		public function sharingIsValid() : Boolean {
			return ( controller.video.shareFBLink && !controller.placement.forceDisableSharing) ? true : false;
		}

		public function dispose() : void {
			unregisterEventListeners();
			disposeChildren();
			colorScheme = null;
			controller = null;
		}

		override public function get visible() : Boolean {
			return super.visible;
		}

		override public function set visible(b : Boolean) : void {
			_visible = b;
			toggle();
		}

		override public function get width() : Number {
			return _width;
		}

		override public function get height() : Number {
			return _height;
		}

		private function clickHandler(e : MouseEvent) : void {
			outHandler();
			controller.shareFacebook();
		}

		private function overHandler(e : MouseEvent) : void {
			bg.transform.colorTransform = colorScheme.highlightCT;
			bg.alpha = colorScheme.highlightAlpha;
		}

		private function outHandler(e : MouseEvent = null) : void {
			bg.transform.colorTransform = colorScheme.baseCT;
			bg.alpha = colorScheme.baseAlpha;
		}

		private function exitFullscreen(e : ResizeEvent) : void {
			outHandler();
		}

		private function toggle() : void {
			if (_enabled && _visible && !controller.video.geoBlocked) {
				super.visible = true;
				this.height = _height;
			} else {
				super.visible = false;
				this.height = 0;
			}
		}

		private function createChildren() : void {
			bg = new Sprite();
			addChild(bg);
		
			var Texture:Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.FacebookIcon);
			var rect:Rectangle =  TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.FacebookIcon);
			icon = new Texture();
			icon.width = rect.width;
			icon.height = rect.height;
			
			addChild(icon);
			centerDisplayObject(icon);
		}

		private function disposeChildren() : void {
			//icon.bitmapData.dispose();
		}

		private function draw() : void {
			bg.graphics.clear();
			bg.graphics.beginFill(0xff0000, 1);
			bg.graphics.drawRect(0, 0, _width, _height);
			bg.graphics.endFill();
		}

		private function setStyle() : void {
			bg.transform.colorTransform = colorScheme.baseCT;
			bg.alpha = colorScheme.baseAlpha;
			icon.transform.colorTransform = colorScheme.primaryCT;
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.floor(this.width / 2 - target.width / 2) ;
			target.y = Math.floor(this.height / 2 - target.height / 2);
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
	}
}