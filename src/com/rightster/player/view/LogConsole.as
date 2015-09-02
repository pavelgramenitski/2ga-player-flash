package com.rightster.player.view {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.utils.Log;
	import flash.display.Sprite;

	/**
	 * @author Daniel Sedlacek
	 */
	public class LogConsole extends Sprite {
		
		private static const PADDING : Number = 5;
		private static const EXPECTED_CHROME_HEIGHT : Number = 70;

		private var controller : IController;
		private var log : Log;

		public function LogConsole(controller : IController) {
			this.controller = controller;
			
			log = Log.getInstance();
			addChild(log);
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			resize();
		}

		private function resize(e : ResizeEvent = null) : void {
			if (log.parent == this) {
				log.resize(controller.width - 2 * PADDING, controller.height - 2 * PADDING - EXPECTED_CHROME_HEIGHT);
				log.x = PADDING;				log.y = PADDING;			}
		}
	}
}
