package com.rightster.player.skin {
	import com.rightster.player.events.LoopModeEvent;
	import com.rightster.player.model.LoopMode;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;
	import com.rightster.player.controller.IController;
	import flash.events.MouseEvent;
	import flash.display.Sprite;	
	import flash.display.MovieClip;

	/**
	 * @author Rightster
	 */
	public class LoopSelector extends MovieClip {
		
		private static const BG_ASSET : String = "bg_mc";
		private static const LOOP_ASSET : String = "loop_mc";
		
		private var controller : IController;
		private var bgAsset : Sprite;
		private var loopAsset : Sprite;		
		private var _enabled : Boolean = false;
		
		public function LoopSelector(controller : IController) {
			this.controller = controller;
			
			_enabled = false;
			toggle();
				
			bgAsset = this[BG_ASSET];
			loopAsset = this[LOOP_ASSET];
			loopAsset.visible = false;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(LoopModeEvent.CHANGE, loopModeChange);
			
			buttonMode = true;
			mouseChildren = false;
			
			setStyle();
			
			loopModeChange();
		}
		
		private function toggle() : void {
			super.visible = _enabled;
		}
		
		private function loopModeChange(e : LoopModeEvent = null) : void {
			switch(controller.loopMode) {
				case LoopMode.PLAYLIST_LOOP :
					loopAsset.visible = true;
				break;
				
				case LoopMode.SINGLE_VIDEO :
					loopAsset.visible = false;
				break;
			}
		}
		
		private function stateChange(e : PlayerStateEvent = null) : void {
			if(controller != null){
				switch (controller.playerState) {
					case PlayerState.VIDEO_READY :
					default:
						resize();
					break;
				}
			}
		}
		
		private function resize(e : ResizeEvent = null) : void {
			if(controller != null){
				if (controller.getPlaylist().length > 1) {
					_enabled = true;
					toggle();
				} else {
					_enabled = false;
					toggle();
				}
			}
		}
		
		private function setStyle() : void {
			bgAsset.transform.colorTransform = Colors.inactiveCT;
			bgAsset.alpha = Colors.baseAlpha;
		}
		
		private function mouseOutHandler(event : MouseEvent) : void {
			setStyle();
		}

		private function mouseOverHandler(event : MouseEvent) : void {
			bgAsset.transform.colorTransform = Colors.highlightCT;
			bgAsset.alpha = Colors.highlightAlpha;
		}
		
		private function clickHandler(event : MouseEvent) : void {
			if (controller.loopMode == LoopMode.PLAYLIST_LOOP) {
				//controller.loopMode = LoopMode.SINGLE_VIDEO;
			}
			else {
				//controller.loopMode = LoopMode.PLAYLIST_LOOP;
			}
		}
		
		public function dispose() : void {		
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			
			controller.removeEventListener(ResizeEvent.RESIZE, resize);
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.removeEventListener(LoopModeEvent.CHANGE, loopModeChange);
			
			controller = null;
		}
	}
}
