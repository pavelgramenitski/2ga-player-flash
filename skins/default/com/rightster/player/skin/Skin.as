package com.rightster.player.skin {
	import com.rightster.player.Version;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.InteractivityEvent;
	import com.rightster.player.events.MonetizationEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.PluginEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;

	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.system.Capabilities;

	/**
	 * @author KJR
	 */
	public class Skin extends MovieClip implements IPlugin {
		public static var isAdvert : Boolean;
		public static const CHROME_HEIGHT : Number = 31;
		private static const NAME : String = "Default skin";
		private static const Z_INDEX : int = PluginZindex.CHROME;
		private static const CHROME_PADDING : Number = 0;
		private static const ADVERT_HEIGHT : Number = 25;
		private static const ADVERT_CHROME_WIDTH : Number = 100;
		private static const SCRUBBER_DEFAULT_HEIGHT : Number = 8;
		private static const VOLUME_DEFAULT_WIDTH : Number = 56;
		private static const VOLUME_DEFAULT_ADV_WIDTH : Number = 28;
		private static const ADV_PADDING : Number = 11;
		// private static const TIMER_Y_PADDING : Number = 48;
		private static const ADVERT_TXT : String = "Advert: {S}s";
		private static const ADVERT_SECONDS : String = "{S}";
		private var controller : IController;
		private var playReplay : PlayReplay;
		private var chromeContainer : Sprite;
		private var chrome : Chrome;
		private var playPauseReplay : PlayPauseReplay;
		private var fullscreen : Fullscreen;
		private var scrubber : Scrubber;
		private var clock : Clock;
		private var volume : Volume;
		private var quality : Quality;
		private var readMore : SharePermalink;
		private var shareFB : ShareFB;
		private var shareTwitter : ShareTwitter;
		private var emailShare : EmailShare;
		private var embedCode : EmbedCode;
		private var gplus : Gplus;
		private var social : Social;
		private var playlistBar : PlaylistBar;
		private var playlistView : PlaylistView;
		private var _initialized : Boolean;
		private var shareList : Array;
		private var _loaded : Boolean = true;
		private var videoTitle : VideoTitle;
		// private var embedScreen : EmbedScreen;
		// private var permaLinkScreen : PermaLinkScreen;
		// private var timerThumb : TimerThumb;
		private var skipButton : SkipButton;
		private var volumeButton : VolumeButton;
		private var shouldDisplaySkipButton : Boolean = true;
		// TODO: trial capture border
		//private var mouseCaptureBorder : CaptureBorder;

		public function Skin() {
			Log.write("Skin name:" + NAME + " version: " + Version.VERSION, Log.SYSTEM);
			this.blendMode = BlendMode.LAYER;
		}

		/*
		 * 
		 * PUBLIC METHODS
		 * 
		 */
		public function initialize(controller : IController, data : Object) : void {
			Log.write("Skin.initialize");
			if (!initialized) {
				this.controller = controller;
				shouldDisplaySkipButton = true;
				shareList = [];
				createChildren();
				registerEventListeners();
				_initialized = true;
			}
		}

		public function run(data : Object) : void {
			Log.write("Skin.run");
			if (initialized) {
				// refreshChildren();
			} else {
				Log.write("CANNOT RUN");
			}

			refreshChildren();
		}

		public function close() : void {
			Log.write("Skin.close");
			// refreshChildren();
		}

		public function dispose() : void {
			Log.write("Skin.dispose");
			if (_initialized) {
				// remove all children of chromeContainer
				var k : int = chromeContainer.numChildren;
				while ( k-- ) {
					chromeContainer.removeChildAt(k);
				}

				removeAllChildren();

				playReplay.dispose();
				chrome.dispose();
				playPauseReplay.dispose();
				fullscreen.dispose();
				scrubber.dispose();
				clock.dispose();
				volume.dispose();
				quality.dispose();

				for (var i : int = 0; i < shareList.length; i++) {
					shareList[i].dispose();
				}

				social.dispose();
				playlistBar.dispose();
				playlistView.dispose();
				videoTitle.dispose();

				// embedScreen.dispose();
				// permaLinkScreen.dispose();
				// timerThumb.dispose();
				skipButton.dispose();
				volumeButton.dispose();

				chromeContainer = null;
				playReplay = null;
				playlistView = null;
				skipButton = null;
				volumeButton = null;

				unregisterEventListeners();

				controller = null;
				_initialized = false;
			}
		}

		/*
		 * 
		 * GETTERS
		 * 
		 */
		public function get zIndex() : int {
			return Z_INDEX;
		}

		public function get loaded() : Boolean {
			return _loaded;
		}

		public function get initialized() : Boolean {
			return _initialized;
		}

		/*
		 * 
		 * EVENT HANDLERS
		 * 
		 */
		private function monetizationEventHandler(evt : MonetizationEvent) : void {
			isAdvert = true;
			this.visible = false;
			switch(evt.type) {
				case MonetizationEvent.AD_BUFFERING:
					scrubber.setStyleAdvert();
					scrubber.startPosition();
					clock.updateTextDisplay(ADVERT_TXT.replace(ADVERT_SECONDS, "0"));
					break;
				case MonetizationEvent.AD_STARTED:
				case MonetizationEvent.AD_PAUSED:
					skipButton.visible = shouldDisplaySkipButton;
					volumeButton.visible = true;
					// timerThumb.visible = true;
					// timerThumb.startedAdv();
					this.visible = true;
					// timerThumb.pauseResumeTimer(true);
					break;
				case MonetizationEvent.AD_ENDED:
					isAdvert = false;
					skipButton.visible = false;
					volumeButton.visible = false;
					// timerThumb.visible = false;
					scrubber.setStyle();
					scrubber.startPosition();
					clock.updateTextDisplay('');
					this.visible = true;
					layoutChildren();
					break;
				case MonetizationEvent.AD_TIMER:
					// timerThumb.validateDuration(Number(evt.data.duration));
					scrubber.updateAdvert(Number(evt.data.time), Number(evt.data.duration));
					clock.updateTextDisplay(ADVERT_TXT.replace(ADVERT_SECONDS, String(evt.data.remainingTime)));
					this.visible = true;
					break;
				case MonetizationEvent.AD_PLAYING:
					// timerThumb.pauseResumeTimer(false);
					break;
				case MonetizationEvent.AD_SKIPPABLE:
					shouldDisplaySkipButton = true;
					break;
				case MonetizationEvent.AD_NOT_SKIPPABLE:
					shouldDisplaySkipButton = false;
					break;
				case MonetizationEvent.AD_ALLOW_SKIP:
					skipButton.enabled = true;
					break;
				case MonetizationEvent.AD_DISALLOW_SKIP:
					skipButton.enabled = false;
					break;
			}

			// IMPORTANT: MVP2 requirement- always disable skippable ads
			shouldDisplaySkipButton = false;

			resizeEventHandler();
		}

		private function playlistViewEventHandler(event : PlaylistViewEvent) : void {
			// Log.write('Skins.playlistViewEventHandler ' + event.type);
			if (event.type == PlaylistViewEvent.SHOW && !playlistView.showing) {
				chromeContainer.visible = false;
				playReplay.visible = false;
				playlistView.show();
			} else {
				chromeContainer.visible = true;
				playReplay.visible = true;
				playlistView.hide();
			}
		}

		private function playerStateEventChangeHandler(e : PlayerStateEvent = null) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.VIDEO_STARTED :
				case PlayerState.VIDEO_PLAYING :
					isAdvert = false;
					resizeEventHandler();
					break;
				case PlayerState.PLAYLIST_ENDED :
					Log.write(controller.getPlaylist().length);
					Log.write(controller.placement.showPlaylist);
					if (controller.getPlaylist().length > 1 && controller.placement.showPlaylist) {
						controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.SHOW));
					}
					break;
			}
		}

		private function resizeEventHandler(event : ResizeEvent = null) : void {
			layoutChildren();
		}

		private function inactivityHandler(e : InteractivityEvent) : void {
			chromeContainer.alpha = e.transition;

			// prevent playlistBar fade with the chrome if playlistView is showing
			if (playlistBar.visible && !playlistView.showing) {
				playlistBar.alpha = e.transition;
			}

			if (!playlistView.showing) {
				chromeContainer.visible = (chromeContainer.alpha <= 0 ) ? false : true;
			}

			// user can click on the playlist view control button whilst it is fading - override the fade
			if (playlistView.showing) {
				playlistBar.alpha = 1;
			}
		}

		/*
		 * 
		 * PRIVATE METHODS
		 * 
		 */
		private function showEmbedScreen(evt : Event) : void {
			Log.write("Skin.showEmbedScreen * NOT IMPLEMENTED");
			// Features not currently implemented...
			// embedScreen.visible = true;
			// permaLinkScreen.visible = false;
		}

		private function showPermaLink(evt : Event) : void {
			Log.write("Skin.showPermaLink * NOT IMPLEMENTED");
			// Features not currently implemented...
			// permaLinkScreen.visible = true;
			// embedScreen.visible = false;
		}

		private function refreshChildren() : void {
			var event : PluginEvent = new PluginEvent(PluginEvent.REFRESH);
			controller.dispatchEvent(event);
		}

		private function createChildren() : void {

			playReplay = new PlayReplay(controller);
			addChild(playReplay);

			playlistView = new PlaylistView(controller);
			addChild(playlistView);
			playlistView.hide();

			chromeContainer = new Sprite();
			addChild(chromeContainer);

			// bottom bar
			chrome = new Chrome(controller);
			chromeContainer.addChild(chrome);

			playPauseReplay = new PlayPauseReplay(controller);
			chromeContainer.addChild(playPauseReplay);

			fullscreen = new Fullscreen(controller);
			chromeContainer.addChild(fullscreen);

			clock = new Clock(controller);
			chromeContainer.addChild(clock);

			volume = new Volume(controller);
			chromeContainer.addChild(volume);

			quality = new Quality(controller);
			chromeContainer.addChild(quality);

			scrubber = new Scrubber(controller);
			scrubber.chromeHeight = CHROME_HEIGHT;
			if (!controller.video.isLive) {
				chromeContainer.addChild(scrubber);
			}

			readMore = new SharePermalink(controller);
			shareFB = new ShareFB(controller);
			shareTwitter = new ShareTwitter(controller);
			emailShare = new EmailShare(controller);
			embedCode = new EmbedCode(controller);
			gplus = new Gplus(controller);

			shareList = [];
			shareList.push(shareFB);
			shareList.push(shareTwitter);
			shareList.push(emailShare);
			shareList.push(readMore);
			shareList.push(embedCode);
			shareList.push(gplus);

			// Features not currently implemented...
			// timerThumb = new TimerThumb(controller, controller.video);
			// timerThumb.visible = false;
			// chromeContainer.addChild(timerThumb);

			skipButton = new SkipButton(controller);
			skipButton.visible = false;
			chromeContainer.addChild(skipButton);

			volumeButton = new VolumeButton(controller);
			volumeButton.visible = false;
			chromeContainer.addChild(volumeButton);

			social = new Social(controller, shareList);
			chromeContainer.addChild(social);

			videoTitle = new VideoTitle(controller);
			chromeContainer.addChild(videoTitle);

			playlistBar = new PlaylistBar(controller);
			addChild(playlistBar);

			playlistBar.visible = (controller.getPlaylist().length > 1) ? true : false;
			videoTitle.visible = !playlistBar.visible;

			//mouseCaptureBorder = new CaptureBorder();
			//addChild(mouseCaptureBorder);

			// Features not currently implemented...
			/*
			embedScreen = new EmbedScreen(controller);
			embedScreen.visible = false;
			chromeContainer.addChild(embedScreen);

			permaLinkScreen = new PermaLinkScreen(controller);
			permaLinkScreen.visible = false;
			chromeContainer.addChild(permaLinkScreen);
			
			 */
		}

		private function layoutChildren() : void {
			var _width : Number = controller.fullScreen ? Capabilities.screenResolutionX : controller.width;

			videoTitle.x = playPauseReplay.x;
			videoTitle.y = 0;

			videoTitle.width = _width;
			playlistBar.width = _width;
			// playlistView.width = _width;

			playlistBar.x = 0;
			playlistBar.y = 0;
			playlistView.x = 0;
			playlistView.y = playlistBar.y + playlistBar.height;

			// chrome.x = playPauseReplay.x + playPauseReplay.width + CHROME_PADDING;
			chrome.x = 0;

			// volume button
			volumeButton.x = playPauseReplay.x + playPauseReplay.width;

			// temp
			// isNonMonetizedPlaybackState();

			//mouseCaptureBorder.width = _width;
			//mouseCaptureBorder.height = controller.fullScreen ? Capabilities.screenResolutionY : controller.height;

			isAdvertPlaybackState();

			// default isAdvert value is false
			if (!isAdvertPlaybackState() ) {
				// Log.write(" LAYOUT CHILDREN ** NOT ADVERT");
				fullscreen.visible = true;
				playlistBar.visible = (controller.getPlaylist().length > 1) ? true : false;
				videoTitle.visible = !playlistBar.visible;
				// ==

				fullscreen.height = playPauseReplay.height = CHROME_HEIGHT;
				fullscreen.x = Math.round((controller.width + _width) / 2) - fullscreen.width;

				// chrome.width = fullscreen.x - playPauseReplay.x - playPauseReplay.width - CHROME_PADDING * 2;
				chrome.width = _width;
				chrome.height = CHROME_HEIGHT;

				social.visible = quality.visible = true;

				volume.width = VOLUME_DEFAULT_WIDTH;
				// volume.x = chrome.width - (quality.width + social.width + volume.width / 2);
				volume.x = _width - fullscreen.width - quality.width - social.width - volume.width;

				// clock.x = chrome.x;
				clock.x = playPauseReplay.x + playPauseReplay.width;

				// scrubber.width = playPauseReplay.width + chrome.width + fullscreen.width;
				scrubber.width = _width;

				scrubber.height = SCRUBBER_DEFAULT_HEIGHT;

				volume.visible = true;
				volumeButton.visible = false;
			} else {
				// Log.write(" LAYOUT CHILDREN **IS  ADVERT");
				chrome.x = volumeButton.x + volumeButton.width + CHROME_PADDING;
				chrome.width = ADVERT_CHROME_WIDTH;

				chrome.height = ADVERT_HEIGHT;

				// TODO: KJR is fullscreen not visible in advert mode?
				fullscreen.visible = false;
				videoTitle.visible = false;
				playlistBar.visible = false;

				skipButton.visible = shouldDisplaySkipButton;

				fullscreen.height = playPauseReplay.height = ADVERT_HEIGHT;
				fullscreen.x = chrome.x + chrome.width;

				social.visible = quality.visible = false;

				volume.width = VOLUME_DEFAULT_ADV_WIDTH;
				volume.x = playPauseReplay.x + playPauseReplay.width + ADV_PADDING;

				clock.x = volume.x + (volume.width + ADV_PADDING);

				scrubber.width = _width;
				scrubber.height = SCRUBBER_DEFAULT_HEIGHT / 2;

				volume.visible = false;
				volumeButton.visible = true;
			}

			var scrubberHeight : Number = (!controller.video.isLive) ? scrubber.height : 0;

			scrubber.x = playPauseReplay.x;
			scrubber.y = controller.height - scrubberHeight;

			playPauseReplay.y = controller.height - (playPauseReplay.height + scrubberHeight);
			chrome.y = controller.height - (chrome.height + scrubberHeight);
			fullscreen.y = quality.y = social.y = controller.height - (fullscreen.height + scrubberHeight);

			// quality.x = chrome.width;
			quality.x = _width - fullscreen.width - quality.width;
			// social.x = chrome.width - quality.width;
			social.x = _width - fullscreen.width - quality.width - social.width;

			volume.y = chrome.y;

			clock.height = chrome.height;
			clock.y = chrome.y;

			// Features not currently implemented...
			// / always static position
			// embedScreen.x = chrome.width - (quality.width + embedScreen.width);
			// embedScreen.y = chrome.y - embedScreen.height;
			// permaLinkScreen.x = chrome.width - (quality.width + permaLinkScreen.width);
			// permaLinkScreen.y = chrome.y - permaLinkScreen.height;
			// timerThumb.x = _width - timerThumb.width;
			// timerThumb.y = controller.height - (timerThumb.height + TIMER_Y_PADDING);

			// advert skip button
			skipButton.x = _width - skipButton.width;
			skipButton.y = controller.height - (skipButton.height + scrubberHeight);

			volumeButton.y = playPauseReplay.y;

			//			
			// Log.write("Skin -- chrome x = ", chrome.x);
			// Log.write("Skin -- chrome w = ", chrome.width);
			// Log.write("Skin -- chrome h = ", chrome.height);
			// chrome.refresh();
		}

		private function isAdvertPlaybackState() : Boolean {
			var boolValue : Boolean = false;

			switch(controller.playerState) {
				case PlayerState.AD_PLAYING:
				case PlayerState.AD_PAUSED:
				case PlayerState.AD_STARTED:
					boolValue = true;
					break;
				default:
					boolValue = false;
			}

			Log.write("**** Skin::isAdvertPlaybackState *value:" + boolValue, Log.TRACKING);

			return boolValue;
		}

		private function removeAllChildren() : void {
			// remove all children of chromeContainer
			var k : int = chromeContainer.numChildren;
			while ( k-- ) {
				chromeContainer.removeChildAt(k);
			}

			removeChild(chromeContainer);
			removeChild(playlistBar);
			removeChild(playlistView);
			removeChild(playReplay);
		}

		private function registerEventListeners() : void {
			controller.addEventListener(ResizeEvent.EXIT_FULLSCREEN, resizeEventHandler);
			controller.addEventListener(ResizeEvent.RESIZE, resizeEventHandler);
			controller.addEventListener(InteractivityEvent.TRANSITION, inactivityHandler);
			controller.addEventListener(PlayerStateEvent.CHANGE, playerStateEventChangeHandler);
			controller.addEventListener(PlaylistViewEvent.SHOW, playlistViewEventHandler);
			controller.addEventListener(PlaylistViewEvent.HIDE, playlistViewEventHandler);

			controller.addEventListener(InteractivityEvent.SHOW_EMBED_SCREEN, showEmbedScreen);
			controller.addEventListener(InteractivityEvent.SHOW_PERMA_LINK, showPermaLink);

			controller.addEventListener(MonetizationEvent.AD_STARTED, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_PAUSED, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_PLAYING, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_BUFFERING, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_ENDED, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_TIMER, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_SKIPPABLE, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_NOT_SKIPPABLE, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_ALLOW_SKIP, monetizationEventHandler);
			controller.addEventListener(MonetizationEvent.AD_DISALLOW_SKIP, monetizationEventHandler);
		}

		private function unregisterEventListeners() : void {
			controller.removeEventListener(ResizeEvent.EXIT_FULLSCREEN, resizeEventHandler);
			controller.removeEventListener(ResizeEvent.RESIZE, resizeEventHandler);
			controller.removeEventListener(InteractivityEvent.TRANSITION, inactivityHandler);
			controller.removeEventListener(PlayerStateEvent.CHANGE, playerStateEventChangeHandler);
			controller.removeEventListener(PlaylistViewEvent.SHOW, playlistViewEventHandler);
			controller.removeEventListener(PlaylistViewEvent.HIDE, playlistViewEventHandler);

			controller.removeEventListener(InteractivityEvent.SHOW_EMBED_SCREEN, showEmbedScreen);
			controller.removeEventListener(InteractivityEvent.SHOW_PERMA_LINK, showPermaLink);

			controller.removeEventListener(MonetizationEvent.AD_STARTED, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_PAUSED, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_PLAYING, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_BUFFERING, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_ENDED, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_TIMER, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_SKIPPABLE, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_NOT_SKIPPABLE, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_ALLOW_SKIP, monetizationEventHandler);
			controller.removeEventListener(MonetizationEvent.AD_DISALLOW_SKIP, monetizationEventHandler);
		}
	}
}