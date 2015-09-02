package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;
	import com.rightster.utils.Log;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;


	/**
	 * @author Sidharth
	 */
	public class ReadMore extends Sprite {
		
		private static const I_ASSET : String = "i_mc";
		private static const MOREINFO_ASSET : String = "moreInfo_mc";
		private static const BG_ASSET : String = "bg_mc";
				
		private var controller : IController;
		private var iAsset : Sprite;
		private var moreInfoAsset : Sprite;
		private var bgAsset : Sprite;
		private var _visible : Boolean = true;
		private var _enabled : Boolean = false;
		private var _height : Number;
		
		override public function get visible() : Boolean {
			return super.visible;
		}
		
		override public function set visible(b : Boolean) : void {
			_visible = b;
			toggle();
		}
		
		override public function get height() : Number {
			return _height;
		}
		
		public function ReadMore(controller : IController) : void {
			this.controller = controller;
			
			iAsset = this[I_ASSET];
			bgAsset = this[BG_ASSET];
			moreInfoAsset = this[MOREINFO_ASSET];
			
			iAsset.visible = true;
			moreInfoAsset.visible = false;
			bgAsset.visible = true;
			buttonMode = true;
						
			addEventListener(MouseEvent.CLICK,clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			
			setStyle();
		}
		
		private function toggle() : void {
			if (_enabled && _visible && !controller.video.geoBlocked) {
				super.visible = true;
				_height = super.height + Skin.ICONS_V_GAP;
			} else {
				super.visible = false;
				_height = 0;
			}
		}

		private function setStyle() : void {
			iAsset.transform.colorTransform = Colors.primaryCT;	
			moreInfoAsset.transform.colorTransform = Colors.primaryCT;
			bgAsset.transform.colorTransform = Colors.baseCT;
			bgAsset.alpha = Colors.baseAlpha;
		}
		
		private function stateChange(e : PlayerStateEvent) : void {
			if (controller.video.readMoreUrl) {
				switch (controller.playerState) {
					case PlayerState.VIDEO_READY :
						_enabled = true;
						toggle();
					break;
					
					case PlayerState.VIDEO_STARTED :
						_enabled = true;
						toggle();
					break;
					
					case PlayerState.AD_STARTED :
						_enabled = false;
						toggle();
					break;
				}
			} else {
				_enabled = false;
				toggle();
			}
		}
		
		private function clickHandler(e : MouseEvent) : void {
			controller.fullScreen = false;
			controller.pauseVideo();
			outHandler();
			Log.write("ReadMore.clickHandler * readMoreUrl: "+controller.video.readMoreUrl, Log.NET);
			navigateToURL(new URLRequest(controller.video.readMoreUrl), "_blank");
		}
	
		private function overHandler(e : MouseEvent) : void {
			bgAsset.transform.colorTransform = Colors.highlightCT;
			bgAsset.alpha = Colors.highlightAlpha;
			iAsset.visible = false;
			moreInfoAsset.visible = true;
		}
		
		private function outHandler(e : MouseEvent = null) : void {
			bgAsset.transform.colorTransform = Colors.baseCT;
			bgAsset.alpha = Colors.baseAlpha;
			iAsset.visible = true;
			moreInfoAsset.visible = false;		
		}
		
		private function exitFullscreen(e : ResizeEvent) : void {
			outHandler();
		}
		
		public function dispose() : void {
			removeEventListener(MouseEvent.CLICK,clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			controller = null;
		}
	}
}