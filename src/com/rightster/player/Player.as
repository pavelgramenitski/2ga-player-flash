package com.rightster.player {
	import com.rightster.player.controller.Controller;
	import com.rightster.player.model.Model;
	import com.rightster.player.view.View;
	import com.rightster.utils.Log;

	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	import flash.events.UncaughtErrorEvent;
	import flash.system.Capabilities;
	import flash.system.Security;


	// import flash.events.UncaughtErrorEvent;

	/**
	 * @author Daniel
	 */
	[SWF(width="640", height="360", frameRate="60", backgroundColor="#000000")]
	public class Player extends Sprite {
		private var controller : Controller;
		private var model : Model;
		private var view : View;

		public function Player() {
			Security.allowDomain("*");
			Log.write('Rightster Player * version: ' + Version.VERSION, Log.SYSTEM);
			Log.write('Flash Player * version: ' + Capabilities.version, Log.SYSTEM);
			this.addEventListener(Event.ADDED_TO_STAGE, stageInit);

		}

		private function stageInit(e : Event) : void {
			Log.write('GPU acceleration: ' + stage.wmodeGPU);
			Log.write('---');
			Log.resetTime();
			removeEventListener(Event.ADDED_TO_STAGE, stageInit);
			//TODO: temp remove pending investigation of effect on other error handling
			//loaderInfo.uncaughtErrorEvents.addEventListener(UncaughtErrorEvent.UNCAUGHT_ERROR, handleUncaughtErrorEvent);

			stage.align = StageAlign.TOP_LEFT;
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.stageFocusRect = false;

			model = new Model(this.loaderInfo);
			view = new View(this.stage);
			controller = new Controller(model, view);

			controller.initialize();
		}

//		private function handleUncaughtErrorEvent(event : UncaughtErrorEvent) : void {
//			event.preventDefault();
//			Log.write('Player.handleUncaughtErrorEvent', Log.ERROR);
//		}
	}
}
