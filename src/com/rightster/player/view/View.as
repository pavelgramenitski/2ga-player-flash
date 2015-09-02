package com.rightster.player.view {
	import flash.events.MouseEvent;
	import com.gskinner.motion.GTweener;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;

	import flash.display.BlendMode;
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.display.StageDisplayState;
	import flash.events.Event;
	import flash.events.FullScreenEvent;
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	/**
	 * @author Daniel
	 */
	public class View {
		private static const FADE_IN_TIME : Number = 0.5;
		// seconds
		private static const SILENT_LOADING_TIME : Number = 1000;
		// miliseconds
		private var controller : IController;
		private var _width : Number;
		private var _height : Number;
		private var _fullScreen : Boolean;
		private var _stage : Stage;
		private var allContainer : Sprite;
		private var contentContainer : Sprite;
		private var screenContainer : Sprite;
		private var videoScreen : VideoScreen;
		private var pluginContainers : Array;
		private var screenshot : Screenshot;
		private var logConsole : LogConsole;
		private var contextMenu : ContextMenuManager;
		private var interactivity : InteractivityManager;
		private var bg : Sprite;
		private var idleIcon : IdleIcon;
		private var _errorScreen : ErrorScreen;
		private var silentLoader : Timer;

		public function get errorScreen() : ErrorScreen {
			return _errorScreen;
		}

		public function get width() : Number {
			return _width;
		}

		public function get height() : Number {
			return _height;
		}

		public function get fullScreen() : Boolean {
			return _fullScreen;
		}

		public function set fullScreen(b : Boolean) : void {
			Log.write('View.set fullscreen * ' + b);
			if (b) {
				try {
					_stage.displayState = StageDisplayState.FULL_SCREEN;
				} catch (err : SecurityError) {
					controller.error(ErrorCode.FULLSCREEN_UNAVAILABLE, "View.fullScreen * " + err.message);
				}
			} else {
				try {
					_stage.displayState = StageDisplayState.NORMAL;
				} catch (err : SecurityError) {
					controller.error(ErrorCode.FULLSCREEN_UNAVAILABLE, "View.fullScreen * " + err.message);
				}
			}
		}

		public function get stage() : Stage {
			return _stage;
		}

		public function get screen() : Sprite {
			return screenContainer;
		}

		public function View(_stage : Stage) {
			this._stage = _stage;
			_width = _stage.stageWidth;
			_height = _stage.stageHeight;

			allContainer = new Sprite();
			_stage.addChild(allContainer);

			silentLoader = new Timer(SILENT_LOADING_TIME, 1);
			silentLoader.addEventListener(TimerEvent.TIMER_COMPLETE, slinetLoadComplete);
			silentLoader.start();
		}

		public function initialize(controller : IController) : void {
			this.controller = controller;
			controller.addEventListener(PlayerStateEvent.CHANGE, onReady);

			bg = new Sprite();
			bg.graphics.beginFill(0x000000);
			bg.graphics.drawRect(0, 0, 1, 1);
			allContainer.addChild(bg);

			contentContainer = new Sprite();
			allContainer.addChild(contentContainer);

			screenContainer = new Sprite();
			contentContainer.addChild(screenContainer);

			videoScreen = new VideoScreen(controller);
			screenContainer.addChild(videoScreen);

			screenshot = new Screenshot(controller);
			screenContainer.addChild(screenshot);

			pluginContainers = [];
			for (var i : int = 0; i < PluginZindex.NUMBER_OF_LAYERS; i++) {
				var layer : Sprite = new Sprite();
				contentContainer.addChild(layer);
				pluginContainers.push(layer);
			}

			idleIcon = new IdleIcon(controller);
			allContainer.addChild(idleIcon);

			_errorScreen = new ErrorScreen(controller);
			allContainer.addChild(_errorScreen);

			logConsole = new LogConsole(controller);
			allContainer.addChild(logConsole);

			contextMenu = new ContextMenuManager(controller, allContainer);

			interactivity = new InteractivityManager(controller);

			contentContainer.alpha = 0;
			contentContainer.blendMode = BlendMode.LAYER;
			idleIcon.alpha = 0;

			resize();
			_stage.addEventListener(Event.RESIZE, resize);
			
			//_stage.addEventListener(FullScreenEvent., resize);
			_stage.addEventListener(FullScreenEvent.FULL_SCREEN, fullscreenHandler);
		}

		public function addPlugin(plugin : IPlugin, zIndex : int) : void {
			Log.write('View.addPlugin * zIndex: ' + plugin + ' * zIndex: ' + zIndex);
			(pluginContainers[zIndex] as DisplayObjectContainer).addChild(plugin as DisplayObject);
		}

		public function addScreenshot(child : DisplayObject) : void {
			Log.write('View.addScreenshot');
			screenshot.addChild(child);
			// /resize();
		}

		public function addVideoScreen(child : DisplayObject) : void {
			Log.write('View.addVideoScreen: ' + child);
			// only add once
			if (child.parent == videoScreen) {
				Log.write('View.addVideoScreen * child already added: ' + child);
			} else {
				videoScreen.addChild(child);
			}

			// /resize();
		}

		public function removeVideoScreen(child : DisplayObject) : void {
			Log.write('View.removeVideoScreen: ' + child);

			try {
				if (child.parent == videoScreen) {
					videoScreen.removeChild(child);
				} else {
					child.parent.removeChild(child);
				}
			} catch(error : Error) {
				Log.write('View.removeVideoScreen *error:' + error, Log.ERROR);
			}

			// /resize();
		}

		private function onReady(e : PlayerStateEvent) : void {
			if (e.state == PlayerState.PLAYER_READY) {
				resize();
				GTweener.to(contentContainer, FADE_IN_TIME, {alpha:1});
			} else if (e.state == PlayerState.PLAYER_UNSTARTED) {
				contentContainer.alpha = 0;
			}
		}

		private function slinetLoadComplete(event : TimerEvent) : void {
			idleIcon.alpha = 1;
		}

		private function resize(e : Event = null) : void {
			_width = _stage.stageWidth;
			_height = _stage.stageHeight;

			bg.width = _width;
			bg.height = _height;
			idleIcon.x = _width / 2;
			idleIcon.y = _height / 2;

			controller.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		}

		private function fullscreenHandler(e : FullScreenEvent) : void {
			if (_stage.displayState == StageDisplayState.FULL_SCREEN || _stage.displayState == StageDisplayState.FULL_SCREEN_INTERACTIVE) {
				_fullScreen = true;
				controller.dispatchEvent(new ResizeEvent(ResizeEvent.ENTER_FULLSCREEN));
			} else {
				_fullScreen = false;
				controller.dispatchEvent(new ResizeEvent(ResizeEvent.EXIT_FULLSCREEN));
			}

			//controller.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		}
	}
}