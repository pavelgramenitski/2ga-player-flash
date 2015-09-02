package com.rightster.player.skin {
	import com.rightster.player.view.Colors;
	import flash.events.MouseEvent;
	import flash.display.Sprite;
	import com.rightster.player.controller.IController;
	import flash.display.MovieClip;

	/**
	 * @author Rightster
	 */
	public class PlayListPrevButton extends MovieClip {
		private static const BG_ASSET : String = "bg_mc";
		private static const ARROW_ASSET : String = "arrow_prev";
		
		private var controller : IController;
		private var bgAsset : Sprite;
		private var arrowAsset : Sprite;
		
		public function PlayListPrevButton(controller : IController) {
			this.controller = controller;
			
			bgAsset = this[BG_ASSET];
			arrowAsset = this[ARROW_ASSET];
			
			addEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			addEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			
			buttonMode = true;
			mouseChildren = false;
			
			setStyle();
		}
		
		private function setStyle() : void {
			bgAsset.alpha = Colors.highlightOffAlpha;
			arrowAsset.transform.colorTransform = Colors.primaryCT;
		}
		
		private function mouseOutHandler(event : MouseEvent) : void {
			arrowAsset.transform.colorTransform = Colors.primaryCT;
		}

		private function mouseOverHandler(event : MouseEvent) : void {
			arrowAsset.transform.colorTransform = Colors.highlightCT;
		}
		
		public function dispose() : void {
			removeEventListener(MouseEvent.MOUSE_OVER, mouseOverHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, mouseOutHandler);
			controller = null;
		}
	}
}
