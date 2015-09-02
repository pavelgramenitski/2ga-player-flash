package com.rightster.player.view {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;

	import flash.display.Sprite;

	/**
	 * @author Daniel
	 */
	public class VideoScreen extends Sprite {
		
		private var controller : IController;
		
		public function VideoScreen(controller : IController) {
			this.controller = controller;
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			
			//for debuging purpose change the color 
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 10, 10);
			graphics.endFill();
		}

		private function resize(e : ResizeEvent) : void {
			//don't resize if stream is not defined
			if (controller.stream == null) {
				return;
			}
			
			//keep aspect ratio
			if (controller.width / controller.height > controller.stream.aspectRatio) {            
				height = Math.round(controller.height);
				width = Math.round(height * controller.stream.aspectRatio);
			} else {
				width = Math.ceil(controller.width);
				height = Math.ceil(width / controller.stream.aspectRatio);
			}
			 
			//apply pixel limit
			if (controller.video.pixelLimit > 0 && controller.video.pixelLimit < width * height) {
				var oversize : Number = width * height / controller.video.pixelLimit;
				width = width / Math.sqrt(oversize);
				height = height / Math.sqrt(oversize); 	
			}
			
			//allign in the middle
			x = Math.round(controller.width / 2 - width / 2);
			y = Math.round(controller.height / 2 - height / 2);
		}
	}
}
