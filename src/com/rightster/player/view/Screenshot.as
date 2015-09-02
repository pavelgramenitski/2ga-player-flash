package com.rightster.player.view {
	import com.rightster.player.events.ModelEvent;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.PlayerState;

	import flash.display.Sprite;

	/**
	 * @author Daniel
	 */
	public class Screenshot extends Sprite {
		private var controller : IController;

		public function Screenshot(controller : IController) {
			this.controller = controller;
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(ModelEvent.SCREENSHOT_SHOW, modelEventHandler);
			controller.addEventListener(ResizeEvent.RESIZE, resize);

			// for debuging purpose change the color
			graphics.beginFill(0x000000);
			graphics.drawRect(0, 0, 10, 10);
		}

		private function stateChange(e : PlayerStateEvent) : void {
			switch(controller.playerState) {
				case PlayerState.VIDEO_CUED:
					this.visible = (controller.placement.autoPlay) ? false : true;
				case PlayerState.PLAYLIST_ENDED:
					this.visible = true;
					break;
				default:
					this.visible = false;
			}
		}

		private function modelEventHandler(event : ModelEvent) : void {
			if (event.type == ModelEvent.SCREENSHOT_SHOW) {
				resize();
				this.visible = true;
			}
		}

		private function resize(e : ResizeEvent = null) : void {
			// don't resize if stream is not defined
			if (controller.stream != null) {
				if (controller.width / controller.height > controller.stream.aspectRatio) {
					height = Math.round(controller.height);
					width = Math.round(height * controller.stream.aspectRatio);
					x = Math.round(controller.width / 2 - width / 2);
					y = 0;
				} else {
					width = Math.round(controller.width);
					height = Math.round(width / controller.stream.aspectRatio);
					y = Math.round(controller.height / 2 - height / 2);
					x = 0;
				}
			}
		}
	}
}