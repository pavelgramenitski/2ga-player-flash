package com.rightster.player.skin {
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.controller.IController;
	import com.rightster.player.view.Colors;
	import flash.display.Sprite;
	import flash.events.MouseEvent;


	/**
	 * @author Daniel
	 */
	public class PlaylistButton extends Sprite {
		private var controller : IController;
		private var _visible : Boolean = true;
		private var _enabled : Boolean = false;
		private var _width : Number;
		
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
			
		public function PlaylistButton(controller : IController) : void {
			this.controller = controller;
			mouseChildren = false;
			
			if (controller.placement.showPlaylist && controller.getPlaylist().length > 1) {
				_enabled = true;
			} else {
				_enabled = false;
			}
			toggle();
			
			buttonMode = true;
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);	
			
			outHandler();
			
			controller.addEventListener(MonetizationEvent.AD_STARTED, disableButton);
			controller.addEventListener(MonetizationEvent.AD_BUFFERING, disableButton);
			controller.addEventListener(MonetizationEvent.AD_ENDED, enableButton);
		}
		
		private function enableButton(evt : MonetizationEvent = null) : void {
			if (controller.placement.showPlaylist && controller.getPlaylist().length > 1) {
				_enabled = true;
			} else {
				_enabled = false;
			}
			toggle();
		}
		
		private function disableButton(evt : MonetizationEvent = null) : void {
			_enabled = false;
			toggle();
		}
		
		private function toggle() : void {
			if (_enabled && _visible) {
				super.visible = true;
				_width = super.width;
			} else {
				super.visible = false;
			}
		}

		private function clickHandler(e : MouseEvent) : void {
			controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.SHOW));
		}
		
		private function overHandler(e : MouseEvent) : void {
			this.transform.colorTransform = Colors.highlightCT;
		}
	
		private function outHandler(e : MouseEvent = null) : void {
			this.transform.colorTransform = Colors.primaryCT;
		}

		public function dispose() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);	
			
			controller.removeEventListener(MonetizationEvent.AD_STARTED, disableButton);
			controller.removeEventListener(MonetizationEvent.AD_BUFFERING, disableButton);
			controller.removeEventListener(MonetizationEvent.AD_ENDED, enableButton);
			
			controller = null;
		}
	}
}
