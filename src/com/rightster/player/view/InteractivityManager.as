package com.rightster.player.view {
	import com.gskinner.motion.GTween;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.InteractivityEvent;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import com.rightster.utils.Log;

	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author KJR
	 */
	public class InteractivityManager {
		private const TRANSITION : String = 'transition';
		private const EXPAND_TIME : Number = 0.1;
		private const SHRINK_TIME : Number = 0.4;
		private const INACTIVITY_TIME : Number = 1500;
		private var controller : IController;
		private var transitionTween : GTween;
		private var tweenObj : Object;
		private var inactivityTimer : Timer;
		private var controlsShowing : Boolean = false;
		private var controlsEnabled : Boolean = false;
		private var isMouseOut : Boolean = false;
		private var mouseEventHandlerRegistered : Boolean = false;

		public function InteractivityManager(controller : IController) : void {
			this.controller = controller;
			tweenObj = {};
			tweenObj[TRANSITION] = 1;
			transitionTween = new GTween(tweenObj);

			transitionTween.paused = true;
			transitionTween.dispatchEvents = true;
			transitionTween.addEventListener('change', transitionTweenChangeHandler);

			inactivityTimer = new Timer(INACTIVITY_TIME, 1);
			inactivityTimer.addEventListener(TimerEvent.TIMER_COMPLETE, inactivityHandler);

			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateChangeHandler);
			controller.addEventListener(MonetizationEvent.AD_OVERLAY_STARTED, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_OVERLAY_ENDED, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_OVERLAY_MINIMIZE, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_OVERLAY_MAXIMIZE, monetizationEventHandler);

			controller.addEventListener(MonetizationEvent.AD_PLAYING, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_PAUSED, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_TIMER, monetizationEventHandler);
		}

		private function mouseOverEventHandler(evt : MouseEvent) : void {
			// Log.write("InterActivityManager::mouseOverEventHandler");
			if (controller.placement.mouseOverContentUnmute && controller.isMuted()) {
				controller.unMute();
			}

			isMouseOut = false;
			if (controller.placement.autoPlayOnMouseOver && !controller.placement.autoPlayDisableOnUserClick) {
				if (controller.playerState != PlayerState.VIDEO_PLAYING && controller.playerState >= PlayerState.PLAYER_READY && controller.playerState <= PlayerState.VIDEO_PAUSED) {
					controller.playVideo();
					controller.placement.autoPlayOnMouseOver = false;
				}
			}
		}

		private function mouseOutEventHandler(evt : Event = null) : void {
			// Log.write("InterActivityManager::mouseOutEventHandler");
			if (controller.placement.mouseOverContentUnmute && !controller.isMuted()) {
				controller.mute();
			}

			isMouseOut = true;
		}

		private function mouseLeaveEventHandler(e : Event) : void {
			// Log.write("InterActivityManager::mouseLeaveEventHandler");
			if (controlsShowing) {
				hideControls();
			}
		}

		private function mouseMoveEventHandler(e : MouseEvent) : void {
			// Log.write("InterActivityManager::mouseMoveEventHandler *controlsShowing: " + controlsShowing);
			inactivityTimer.reset();
			inactivityTimer.start();
			if (!controlsShowing) {
				showControls();
			}
		}

		private function playerStateChangeHandler(e : PlayerStateEvent) : void {
			switch (controller.playerState) {
				case PlayerState.AD_STARTED :
				case PlayerState.VIDEO_STARTED :
					hideControls();
					enableControls();
					break;
				case PlayerState.VIDEO_CUED :
				case PlayerState.PLAYLIST_ENDED :
					disableControls();
					showControls();
					break;
				case PlayerState.VIDEO_READY :
					registerMouseEventHandlers();
					break;
			}
		}

		private function monetizationEventHandler(evt : MonetizationEvent) : void {
			Log.write("Liverail::monetizationEventHandler * evt: " + evt);
			switch (evt.type) {
				case MonetizationEvent.AD_OVERLAY_ENDED :
				case MonetizationEvent.AD_OVERLAY_MINIMIZE :
					showControls();
					enableControls();
					break;
				case MonetizationEvent.AD_OVERLAY_STARTED :
				case MonetizationEvent.AD_OVERLAY_MAXIMIZE :
					hideControls();
					disableControls();
					break;
				case MonetizationEvent.AD_PAUSED :
					// Log.write("Liverail::monetizationEventHandler * MonetizationEvent.AD_PAUSED");
					disableControls();
					showControls();
					break;
				case MonetizationEvent.AD_PLAYING :
					// Log.write("Liverail::monetizationEventHandler * MonetizationEvent.AD_PAUSED");
					hideControls();
					enableControls();
					break;
				case MonetizationEvent.AD_TIMER :
					// Log.write("Liverail::monetizationEventHandler * MonetizationEvent.AD_PAUSED");
					// hideControls();
					if (!controlsEnabled) {
						enableControls();

						if (controller.playerState == PlayerState.AD_PAUSED) {
							Log.write("Liverail::monetizationEventHandler * MonetizationEvent.AD_TIMER WITH PlayerState.AD_PAUSED");
							controller.dispatchEvent(new MonetizationEvent(MonetizationEvent.AD_PLAYING));
						}
					}
					break;
			}
		}

		private function inactivityHandler(e : TimerEvent) : void {
			if (controlsShowing) {
				hideControls();
			}
			if (isMouseOut) {
				mouseOutEventHandler();
			}
		}

		private function transitionTweenChangeHandler(e : Event = null) : void {
			controller.dispatchEvent(new InteractivityEvent(InteractivityEvent.TRANSITION, tweenObj[TRANSITION]));
		}

		private function enableControls() : void {
			Log.write("InterActivityManager::enableControls");
			if (!controlsEnabled) {
				Log.write("InterActivityManager::enableControls SUCCESS");
				controlsEnabled = true;
				controller.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
				controller.stage.addEventListener(Event.MOUSE_LEAVE, mouseLeaveEventHandler);
				inactivityTimer.reset();
				inactivityTimer.start();
			}
		}

		private function disableControls() : void {
			Log.write("InterActivityManager::disableControls");
			if (controlsEnabled) {
				Log.write("InterActivityManager::disableControls SUCCESS");
				controlsEnabled = false;
				controller.stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveEventHandler);
				controller.stage.removeEventListener(Event.MOUSE_LEAVE, mouseLeaveEventHandler);
				inactivityTimer.stop();
			}
		}

		private function showControls() : void {
			// Log.write("InterActivityManager::showControls..");
			if (!controlsShowing) {
				// Log.write("CAN EXPAND");
				controlsShowing = true;
				transitionTween.duration = EXPAND_TIME;
				transitionTween.proxy[TRANSITION] = 1;
			}
		}

		private function hideControls() : void {
			// Log.write("InterActivityManager::hideControls");
			controlsShowing = false;
			transitionTween.duration = SHRINK_TIME;
			transitionTween.proxy[TRANSITION] = 0;
		}

		private function registerMouseEventHandlers() : void {
			if (!mouseEventHandlerRegistered) {
				// Log.write("InterActivityManager::registerMouseEventHandlers - success");
				mouseEventHandlerRegistered = true;
				controller.stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseOverEventHandler);
				controller.stage.addEventListener(Event.MOUSE_LEAVE, mouseOutEventHandler);
			}
		}
	}
}
