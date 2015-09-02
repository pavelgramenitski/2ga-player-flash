package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.events.VolumeEvent;
	import com.rightster.player.view.IColors;

	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;

	/**
	 * @author KJR
	 */
	public class VolumeButton extends Sprite {
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : Sprite;
		private var iconOn : DisplayObject;
		private var iconOff : DisplayObject;
		private var _enabled : Boolean;
		private var _muted : Boolean;
		private var _width : Number = 45;
		private var _height : Number = 25;
		private var _padding : Number = 0;

		public function VolumeButton(controller : IController) {
			this.controller = controller;
			colorScheme = this.controller.colors;
			buttonMode = true;
			mouseChildren = false;
			_enabled = true;
			_muted = controller.isMuted();
			createChildren();
			registerEventListeners();
			setInitialDisplayState();
		}

		public function dispose() : void {
			unregisterEventListeners();
			disposeChildren();
			removeChildren(0, numChildren - 1);
			bg = null;
			iconOn = null;
			iconOff = null;
			controller = null;
			colorScheme = null;
		}

		override public function set width(w : Number) : void {
			_width = w;
			draw();
			layout();
		}

		override public function set height(h : Number) : void {
			_height = h;
			draw();
			layout();
		}

		public function get padding() : Number {
			return _padding;
		}

		public function set padding(value : Number) : void {
			_padding = value;
		}

		public function get enabled() : Boolean {
			return _enabled;
		}

		public function set enabled(value : Boolean) : void {
			_enabled = value;
			_enabled ? enableButton() : disableButton();
		}

		public function get muted() : Boolean {
			return _muted;
		}

		public function set muted(value : Boolean) : void {
			_muted = value;
			setMutedState();
		}

		private function clickHandler(e : MouseEvent) : void {
			if (_enabled) {
				_muted = !_muted;
				_muted ? controller.mute() : controller.unMute();
				setMutedState();
			}
		}

		private function overHandler(e : MouseEvent) : void {
			if (_enabled) {
				bg.transform.colorTransform = colorScheme.advertCT;
			}
		}

		private function outHandler(e : MouseEvent = null) : void {
			if (_enabled) {
				bg.transform.colorTransform = colorScheme.baseCT;
			}
		}

		private function exitFullscreen(e : ResizeEvent) : void {
			if (_enabled) {
				outHandler();
			}
		}

		private function setSpeaker(e : VolumeEvent = null) : void {
			_muted = controller.isMuted() ? true : false;
			setMutedState();
		}

		private function createChildren() : void {
			bg = new Sprite();
			addChild(bg);

			var Texture:Class = TextureAtlas.getNewTextureClassByName(TextureAtlas.VolumeSpeakerAdvertOnIcon);
			var rect:Rectangle =  TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.VolumeSpeakerAdvertOnIcon);
			iconOn = new Texture();
			iconOn.width = rect.width;
			iconOn.height = rect.height;
			addChild(iconOn);

			Texture = TextureAtlas.getNewTextureClassByName(TextureAtlas.VolumeSpeakerAdvertMutedIcon);
			rect =  TextureAtlas.getTextureClassDimensionsByName(TextureAtlas.VolumeSpeakerAdvertMutedIcon);
			iconOff = new Texture();
			iconOff.width = rect.width;
			iconOff.height = rect.height;
			addChild(iconOff);
		}

		private function disposeChildren() : void {
			//iconOn.bitmapData.dispose();
			//iconOff.bitmapData.dispose();
		}

		private function setInitialDisplayState() : void {
			draw();
			layout();
			enableButton();
			setMutedState();
			setStyle();
		}

		private function setMutedState() : void {
			iconOff.visible = (_muted) ? true : false;
			iconOn.visible = !iconOff.visible;
		}

		private function setStyle() : void {
			iconOn.transform.colorTransform = colorScheme.primaryCT;
			iconOff.transform.colorTransform = colorScheme.primaryCT;
		}

		private function draw() : void {
			bg.graphics.clear();
			bg.graphics.beginFill(0xff0000, 1);
			bg.graphics.drawRect(0, 0, _width, _height);
			bg.graphics.endFill();
		}

		private function layout() : void {
			centerDisplayObject(iconOn);
			centerDisplayObject(iconOff);
		}

		private function registerEventListeners() : void {
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);

			controller.addEventListener(VolumeEvent.MUTE, setSpeaker);
			controller.addEventListener(VolumeEvent.UNMUTE, setSpeaker);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
		}

		private function unregisterEventListeners() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);

			controller.removeEventListener(VolumeEvent.MUTE, setSpeaker);
			controller.removeEventListener(VolumeEvent.UNMUTE, setSpeaker);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
		}

		private function enableButton() : void {
			buttonMode = true;
			bg.transform.colorTransform = colorScheme.baseCT;
		}

		private function disableButton() : void {
			buttonMode = false;
			bg.transform.colorTransform = colorScheme.inactiveCT;
		}

		private function centerDisplayObject(target : DisplayObject) : void {
			target.x = Math.floor(this.width / 2 - target.width / 2) ;
			target.y = Math.floor(this.height / 2 - target.height / 2);
		}
	}
}
