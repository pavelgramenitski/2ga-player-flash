package com.rightster.player.view {
	import com.gskinner.motion.GTween;
	import com.gskinner.motion.GTweener;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.PlayerState;

	import flash.display.Sprite;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Daniel
	 */
	public class IdleIcon extends Sprite {
		private static const MICRO_MODE_MODIFIER : Number = 0.6;
		private static const MICRO_MODE_WIDTH : Number = 300;
		private static const MICRO_MODE_HEIGHT : Number = 220;
		private static const ICON_RADIUS : Number = 25;
		private static const ICON_ROTATION : Number = 5;
		private static const BALL_RADIUS : Number = 4;
		private static const BALL_EXPANSION : Number = 1.8;
		private static const EXPANSION_ROTATION : Number = 80;
		private static const EXPANSION_FADE : Number = 0.5;
		private static const BALL_COUNT : Number = 8;
		private var controller : IController;
		private var balls : Array;
		private var rotationTween : GTween;
		private var timer : Timer;

		public function IdleIcon(controller : IController) {
			this.controller = controller;
			balls = [];

			for (var i : int = 0; i < BALL_COUNT; i++) {
				var ball : Sprite = new Sprite();
				with (ball.graphics) {
					beginFill(0xFFFFFF);
					drawCircle(0, 0, BALL_RADIUS);
				}
				
				ball.x = Math.sin(2 * Math.PI * i / BALL_COUNT) * ICON_RADIUS;
				ball.y = Math.cos(2 * Math.PI * i / BALL_COUNT) * ICON_RADIUS;
				ball.cacheAsBitmap = true;
				balls.push(ball);
				addChild(ball);
			}

			timer = new Timer(EXPANSION_ROTATION, 0);
			timer.addEventListener(TimerEvent.TIMER, timerHandler);
			timer.start();

			rotationTween = new GTween(this, ICON_ROTATION, {rotation:-360}, {repeatCount:0});

			visible = false;
			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateChangeHandler);
			controller.addEventListener(ResizeEvent.RESIZE, resizeHandler);
			resizeHandler();
		}

		private function playerStateChangeHandler(e : PlayerStateEvent) : void {
			if (controller.playerState == PlayerState.PLAYER_BUFFERING) {
				if (timer && !timer.running) {
					timer.start();
				}
				visible = true;
			} else {
				if (timer.running) {
					timer.stop();
				}

				visible = false;
			}
		}

		private function timerHandler(event : TimerEvent) : void {
			var ball : Sprite = balls.pop();
			balls.unshift(ball);
			ball.scaleX = ball.scaleY = BALL_EXPANSION;
			ball.alpha = 1;
			GTweener.to(ball, EXPANSION_FADE, {scaleX:1, scaleY:1, alpha:0.7});
		}

		private function resizeHandler(e : ResizeEvent = null) : void {
			if (controller.width < MICRO_MODE_WIDTH || controller.height < MICRO_MODE_HEIGHT) {
				this.scaleX = this.scaleY = MICRO_MODE_MODIFIER;
			} else {
				this.scaleX = this.scaleY = 1;
			}
		}
	}
}