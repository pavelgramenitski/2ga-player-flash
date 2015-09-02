﻿package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.InteractivityEvent;
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.IPlugin;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.model.PluginZindex;
	import com.rightster.utils.Log;

	import flash.display.BlendMode;
	import flash.display.MovieClip;
	import flash.display.Sprite;


	/**
	 * @author Daniel
	 */
	public class Skin extends MovieClip implements IPlugin {
		
		public static const ICONS_V_GAP       : Number = 10;
		
		private static const VERSION : String = "3.0.1";
		private static const Z_INDEX : int = PluginZindex.CHROME;
		private static const SCREEN1_PADDING    : Number = 20;
		private static const SCREEN2_PADDING    : Number = 10;
		private static const CHROME_PADDING     : Number = 5;
		private static const CHROME_HEIGHT      : Number = 41;
		private static const ICON_SMALL   		: Number = 31;
		private static const ICON_LARGE   		: Number = 41;
		private static const MAX_WIDTH          : Number = 1000;
		private static const MIN1_WIDTH         : Number = 390;
		private static const MIN2_WIDTH         : Number = 220;
		private static const MIN_HEIGHT         : Number = 220;
				
		private var controller          : IController;
		private var playResumeReplay    : PlayResumeReplay;
		private var chromeContainer     : Sprite;
		private var chrome              : Chrome;
		private var playPause           : PlayPause;
		private var fullscreen          : Fullscreen;
		private var scrubber            : Scrubber;
		private var clock               : Clock;
		private var volume              : Volume;
		private var quality             : Quality;
		private var readMore            : ReadMore;
		private var shareFB             : ShareFB;
		private var shareTwitter		: ShareTwitter;
		private var playlistButton 		: PlaylistButton;
		private var playlistView 		: PlaylistView;
		private var initialized 		: Boolean;
		private var emailShare          : EmailShare;
		
		private var shareList          	: Array;
		private var _loaded 			: Boolean = true;
		
		public function Skin() {
			Log.write("Skin version " + VERSION);
			this.blendMode = BlendMode.LAYER;
		}
		
		public function get zIndex() : int {
			return Z_INDEX;
		}
		
		public function get loaded() : Boolean {
			return _loaded;
		}
		
		public function initialize(controller : IController, data : Object) : void {
			Log.write("Skin.initialize");
			this.controller = controller;
			
			initialized = true;
			
			shareList = [];
			
			playResumeReplay = new PlayResumeReplay(controller);
			addChild(playResumeReplay);
						
			playlistView = new PlaylistView(controller);
			addChild(playlistView);
			playlistView.visible = false;
			
			chromeContainer = new Sprite();
			addChild(chromeContainer);
			
			chrome = new Chrome(controller);
			chromeContainer.addChild(chrome);
			
			playPause = new PlayPause(controller);
			chromeContainer.addChild(playPause);
			
			fullscreen = new Fullscreen(controller);
			chromeContainer.addChild(fullscreen);
			
			clock = new Clock(controller);
			chromeContainer.addChild(clock);
						
			volume = new Volume(controller);
			chromeContainer.addChild(volume);
			
			playlistButton = new PlaylistButton(controller);
			chromeContainer.addChild(playlistButton);
			
			quality = new Quality(controller);
			chromeContainer.addChild(quality);
			
			scrubber = new Scrubber(controller);
			if (!controller.video.isLive) {
				chromeContainer.addChild(scrubber);
			}
			
			readMore = new ReadMore(controller);
			readMore.visible = false;
			chromeContainer.addChild(readMore);
				
			shareFB	= new ShareFB(controller);
			shareFB.visible = false;
			chromeContainer.addChild(shareFB);
			
			shareTwitter = new ShareTwitter(controller);
			shareTwitter.visible = false;
			chromeContainer.addChild(shareTwitter);
			
			emailShare = new EmailShare(controller);
			emailShare.visible = false;
			chromeContainer.addChild(emailShare);
			
			shareList.push(shareFB);
			shareList.push(shareTwitter);
			shareList.push(emailShare);
			shareList.push(readMore);
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			controller.addEventListener(InteractivityEvent.TRANSITION, inactivityHandler);
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			controller.addEventListener(PlaylistViewEvent.SHOW, onPlaylistView);
			controller.addEventListener(PlaylistViewEvent.HIDE, onPlaylistView);		
		}

		private function onPlaylistView(event : PlaylistViewEvent) : void {
			if (event.type == PlaylistViewEvent.SHOW) {
				chromeContainer.visible = false;
				playResumeReplay.visible = false;
				playlistView.visible = true;
			} else {
				chromeContainer.visible = true;
				playResumeReplay.visible = true;
				playlistView.visible = false;
			}
		}
		
		private function stateChange(e : PlayerStateEvent = null) : void {
			switch (controller.playerState) {
				case PlayerState.VIDEO_READY :
				case PlayerState.VIDEO_STARTED :
					resize();
				break;
				
				case PlayerState.PLAYLIST_ENDED :
					if (controller.getPlaylist().length > 1 && controller.placement.showPlaylist) {
						controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.SHOW));
					}
				break;	
			}
		}
		
		private function resize(e : ResizeEvent = null) : void {			
			var padding : Number = controller.height < MIN_HEIGHT ? SCREEN2_PADDING : SCREEN1_PADDING;

			var _width : Number = controller.width < MAX_WIDTH ? controller.width : MAX_WIDTH;
			var _y : Number = controller.height - CHROME_HEIGHT - padding;
			
			var size : Number;
			var currItemSize : Number = 0;
			var lastItemSize : Number = 0;
			
			for (var i : int = 0; i< shareList.length; i++ ) {
				shareList[i].visible = true;
				size = controller.height < MIN_HEIGHT ? ICON_SMALL : ICON_LARGE;
				currItemSize = shareList[i].height != 0 ? size + ICONS_V_GAP : 0;
				shareList[i].width = size;
				shareList[i].height = size;
				shareList[i].x = controller.width - currItemSize - padding;
				shareList[i].y = i == 0 ? padding : shareList[i-1].y + lastItemSize;
				lastItemSize = currItemSize;
			}
			
			if (_width < MIN2_WIDTH) {
				playPause.x = padding;
				fullscreen.x = playPause.x + playPause.width + CHROME_PADDING;
				
				quality.visible = false;				
				playlistButton.visible = false;				
				clock.visible = false;	
				chrome.visible = false;
				scrubber.visible = false;
				volume.visible = false;
				
				setShareListOnOff(false);
			} else {
				playPause.x = Math.round((controller.width - _width) / 2) + padding;
				fullscreen.x = Math.round((controller.width + _width) / 2) - padding - fullscreen.width;
				
				chrome.visible = true;
				scrubber.visible = true;
				volume.visible = true;
				if (_width < MIN1_WIDTH) {
					quality.visible = false;				
					playlistButton.visible = false;				
					clock.visible = false;		
				}  else {				
					quality.visible = true;				
					playlistButton.visible = true;				
					clock.visible = true;	
				}
				setShareListOnOff(true);
			}
			
			if (controller.height < MIN_HEIGHT) {
				playResumeReplay.visible = false;
			} else {
				playResumeReplay.visible = true;
			}
			
			playPause.y = _y;
			fullscreen.y = _y;
			
			chrome.x =  playPause.x + playPause.width + CHROME_PADDING;
			chrome.y = _y;
			chrome.width = fullscreen.x - playPause.x - playPause.width - CHROME_PADDING * 2;
			chrome.height = CHROME_HEIGHT;
			
			quality.x = chrome.x + chrome.width - quality.width;
			quality.y = _y;
			
			playlistButton.x = Math.round(quality.x - playlistButton.width);
			playlistButton.y = _y;
			
			volume.x = Math.round((chrome.x+(chrome.width/2))-(volume.width/2));
			volume.y = chrome.y-6;
			
			scrubber.x = chrome.x + 5;
			scrubber.y = _y + CHROME_HEIGHT - 10;
			scrubber.width = chrome.width - 10;
			
			clock.x = chrome.x;
			clock.y = _y;
			
			if (controller.video.isLive) {
				quality.y += 5;
				playlistButton.y += 5;
				volume.y += 5;
				clock.y += 5;
			}
		}
		
		private function setShareListOnOff($flag:Boolean):void{
			for(var i:int=0; i<shareList.length; i++){
				shareList[i].visible = $flag;
			}
		}

		private function inactivityHandler(e : InteractivityEvent) : void {
			chromeContainer.alpha = e.transition;
			if(!playlistView.visible) chromeContainer.visible = (chromeContainer.alpha <= 0 ) ? false : true;
		}
		
		public function dispose() : void {
			if (initialized) {
				//remove all children of chromeContainer
				var k : int = chromeContainer.numChildren;
		        while( k -- ){
		        	chromeContainer.removeChildAt( k );
		        }
				removeChild(chromeContainer);
				removeChild(playlistView);
				removeChild(playResumeReplay);
				
				playResumeReplay.dispose();
				chrome.dispose();
				playPause.dispose();
				fullscreen.dispose();
				scrubber.dispose();
				clock.dispose();
				volume.dispose();
				quality.dispose();
				readMore.dispose();
				shareFB.dispose();
				shareTwitter.dispose();
				emailShare.dispose();
				playlistButton.dispose();
				playlistView.dispose();
				
				chromeContainer = null;
				playResumeReplay = null;
				playlistView = null;
				
				controller.removeEventListener(ResizeEvent.RESIZE, resize);
				controller.removeEventListener(InteractivityEvent.TRANSITION, inactivityHandler);
				controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
				controller.removeEventListener(PlaylistViewEvent.SHOW, onPlaylistView);
				controller.removeEventListener(PlaylistViewEvent.HIDE, onPlaylistView);
						
				controller = null;
			}
		}
	}
}