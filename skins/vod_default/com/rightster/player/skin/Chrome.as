package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.view.Colors;
	import flash.display.MovieClip;


	/**
	 * @author Daniel
	 */
	public class Chrome extends MovieClip {
		private var controller : IController;		
		
		public function Chrome(controller : IController) : void {
			this.controller = controller;			
			
			setStyle();
		}

		private function setStyle() : void {
			this.transform.colorTransform = Colors.baseCT;
			this.alpha = Colors.baseAlpha;
		}

		public function dispose() : void {
			controller = null;
		}
	}
}
