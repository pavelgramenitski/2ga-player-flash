package com.rightster.player.skin {
	import com.rightster.player.model.LoopMode;
	import com.rightster.player.view.Colors;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import com.rightster.player.controller.IController;
	import flash.display.MovieClip;

	/**
	 * @author Rightster
	 */
	public class PlayAllButton extends MovieClip {
		
		private static const BG_ASSET : String = "bg_mc";
		
		private var controller : IController;
		private var bg : Sprite;
		public function PlayAllButton(controller : IController) {
			this.controller = controller;
			
			bg = this[BG_ASSET];
			buttonMode = true;
			
			bg.addEventListener(MouseEvent.CLICK, mouseClickFunc);
			bg.addEventListener(MouseEvent.MOUSE_OVER, mouseOverFunc);
			bg.addEventListener(MouseEvent.MOUSE_OUT, mouseOutFunc);
			
			setStyle();
		}
		
		private function setStyle() : void {
			bg.transform.colorTransform = Colors.backgroundCT;
			bg.alpha = Colors.baseAlpha;
		}
		
		private function mouseOverFunc(e : MouseEvent) : void {
			(e.currentTarget as Sprite).transform.colorTransform = Colors.highlightCT;
		}
		
		private function mouseOutFunc(e : MouseEvent) : void {
			setStyle();
		}
		
		private function mouseClickFunc(e : MouseEvent) : void {
			controller.playVideoAt(0);
			controller.loopMode = LoopMode.PLAYLIST_LOOP;
		}
		
		public function dispose() : void {
			bg.removeEventListener(MouseEvent.CLICK, mouseClickFunc);
			bg.removeEventListener(MouseEvent.MOUSE_OVER, mouseOverFunc);
			bg.removeEventListener(MouseEvent.MOUSE_OUT, mouseOutFunc);
			
			controller = null;
		}
	}
}
