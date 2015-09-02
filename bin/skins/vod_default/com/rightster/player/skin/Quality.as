package com.rightster.player.skin {
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	/**
	 * @author Daniel
	 */
	public class Quality extends MovieClip {
		private static const ICON_ASSET : String = "icon_mc";
		private static const BG_ASSET : String = "bg_mc";
		private static const TRIANGEL_ASSET : String = "quality_triangel";
		private static const GIZMO_ASSET : String = "gizmo_mc";
		private static const QUALTY_BUTTON_X : Number = 2;
		private static const QUALTY_BUTTON_Y : Number = -10;
		private static const QUALTY_BUTTON_PADDING : Number = 2;
		private static const WIDTH : Number = 32;
		private static const HEIGHT : Number = 32;
		
		private var controller : IController;
		private var icon : MovieClip;
		private var bgAsset : Sprite;
		private var bg2Asset : Sprite;
		private var triangelAsset : Sprite;
		private var gizmo : Sprite;
		private var qualityButtons : Array;
		private var levels : Array;
		private var _visible : Boolean = true;
		private var _enabled : Boolean = false;
		private var _width : Number = 0;
		
		override public function get visible() : Boolean {
			return super.visible;
		}
		
		override public function set visible(b : Boolean) : void {
			_visible = b;
			toggle();
		}

		public function Quality(controller : IController) : void {
			this.controller = controller;

			icon = this[ICON_ASSET];
			bgAsset = this[BG_ASSET];
			gizmo = this[GIZMO_ASSET];
			bg2Asset = gizmo[BG_ASSET];
			triangelAsset = gizmo[TRIANGEL_ASSET];
			
			bgAsset.alpha = 0;
			gizmo.visible = false;
			buttonMode = true;
			
			setStyle();
			toggle();
			
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);			
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			
			controller.addEventListener(MonetizationEvent.AD_STARTED, disableButton);
			controller.addEventListener(MonetizationEvent.AD_BUFFERING, disableButton);
			controller.addEventListener(MonetizationEvent.AD_ENDED, enableButton);
		}
		
		private function enableButton(evt : MonetizationEvent = null) : void {
			if (levels == null || levels.length < 2) {
				_enabled = false;
			}else{
				_enabled = true;
			}
			toggle();
		}
		
		private function disableButton(evt : MonetizationEvent = null) : void {
			_enabled = false;
			toggle();
		}		
		
		override public function get width() : Number {
			return _width;
		}
		
		override public function get height() : Number {
			return HEIGHT;
		}
		
		private function toggle() : void {
			if (_enabled && _visible) {
				super.visible = true;
				_width = WIDTH;
			} else {
				super.visible = false;
				_width = 0;
			}
		}
		
		private function setStyle() : void {
			icon.transform.colorTransform = Colors.primaryCT;
			bg2Asset.transform.colorTransform = Colors.baseCT;
			bg2Asset.alpha = Colors.baseAlpha;
			
			triangelAsset.transform.colorTransform = Colors.baseCT;
			triangelAsset.alpha = Colors.baseAlpha;
		}
		
		private function stateChange(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
					generate();
				break;
			}
		}

		private function generate() : void {
			levels = controller.getAvailableQualityLevels();
			if (levels == null || levels.length < 2) {
				_enabled = false;
				toggle();
				return;
			}
			
			
			qualityButtons = [];
			for (var i : int = 0; i < levels.length; i++) {
				var qualityButton : QualityButton = new QualityButton(controller, levels[i]);
				qualityButton.y = QUALTY_BUTTON_Y - (i+1) * qualityButton.height - (i+1) * QUALTY_BUTTON_PADDING;
				qualityButton.x = QUALTY_BUTTON_X;
				gizmo.addChild(qualityButton);
				qualityButtons.push(qualityButton);
			}
			
			bg2Asset.height = levels.length * qualityButton.height + (levels.length+1) * QUALTY_BUTTON_PADDING;
			
			icon.mouseEnabled = false;
			gizmo.visible = false;
			
			_enabled = true;
			toggle();
		}
		
		private function overHandler(e : MouseEvent) : void {
			gizmo.visible = true;
		}

		private function outHandler(e : MouseEvent) : void {
			gizmo.visible = false;
		}

		public function dispose() : void {	
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);		
			
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.removeEventListener(MonetizationEvent.AD_STARTED, disableButton);
			controller.removeEventListener(MonetizationEvent.AD_BUFFERING, disableButton);
			controller.removeEventListener(MonetizationEvent.AD_ENDED, enableButton);
			
			controller = null;
		}
	}
}
