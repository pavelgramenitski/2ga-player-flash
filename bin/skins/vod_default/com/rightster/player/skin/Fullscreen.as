package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.view.Colors;
	import com.rightster.utils.Log;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;


	/**
	 * @author Daniel
	 */
	public class Fullscreen extends MovieClip {
		private static const UP_ASSET : String = "up_mc";
		private static const DOWN_ASSET : String = "down_mc";
		private static const BG_ASSET : String = "bg_mc";
		
		private var controller : IController;
		private var upAsset : Sprite;
		private var downAsset : Sprite;
		private var bgAsset : Sprite;
			
		public function Fullscreen(controller : IController) : void {
			this.controller = controller;
			
			buttonMode = true;
			mouseChildren = false;
			
			addEventListener(MouseEvent.CLICK, clickHandler);
			addEventListener(MouseEvent.MOUSE_OVER, overkHandler);
			addEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			upAsset = this[UP_ASSET];
			downAsset = this[DOWN_ASSET];
			bgAsset = this[BG_ASSET];
			downAsset.visible = false;
			
			controller.addEventListener(ResizeEvent.ENTER_FULLSCREEN, enterFullscreen);
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);
			setStyle();
		}

		private function setStyle() : void {
			upAsset.transform.colorTransform = Colors.primaryCT;	
			downAsset.transform.colorTransform = Colors.primaryCT;	
			bgAsset.transform.colorTransform = Colors.baseCT;	
			bgAsset.alpha = Colors.baseAlpha;
		}

		private function enterFullscreen(e : ResizeEvent) : void {
			upAsset.visible = false;
			downAsset.visible = true;
		}
		
		private function exitFullscreen(e : ResizeEvent) : void {
			upAsset.visible = true;
			downAsset.visible = false;
			outHandler();
		}
		
		private function clickHandler(e : MouseEvent) : void {
			Log.write("Fullscreen.clickHandler * fullscreen: " + controller.fullScreen);
			controller.fullScreen = !controller.fullScreen;
		}
		
		private function overkHandler(e : MouseEvent) : void {
			bgAsset.transform.colorTransform = Colors.highlightCT;	
			bgAsset.alpha = Colors.highlightAlpha;	
		}
		
		private function outHandler(e : MouseEvent = null) : void {
			bgAsset.transform.colorTransform = Colors.baseCT;	
			bgAsset.alpha = Colors.baseAlpha;
		}
		
		public function dispose() : void {
			removeEventListener(MouseEvent.CLICK, clickHandler);
			removeEventListener(MouseEvent.MOUSE_OVER, overkHandler);
			removeEventListener(MouseEvent.MOUSE_OUT, outHandler);
			
			controller.removeEventListener(ResizeEvent.ENTER_FULLSCREEN, enterFullscreen);
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, exitFullscreen);			
			controller = null;
		}
	}
}
