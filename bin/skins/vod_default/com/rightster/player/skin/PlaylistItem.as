package com.rightster.player.skin {
	import com.gskinner.motion.GTweener;
	import com.rightster.player.controller.IController;
	import com.rightster.player.model.ErrorCode;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.view.Colors;
	import com.rightster.utils.Log;
	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.events.AsyncErrorEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.MouseEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLRequest;
	import flash.text.TextField;

	/**
	 * @author Daniel
	 */
	public class PlaylistItem extends Sprite {
		
		public static const WIDTH : Number = 140;
		public static const HEIGHT : Number = 79;
		
		private static const BG_ASSET : String = "bg_mc";
		private static const TITLE_ASSET : String = "title_txt";
		private static const DURATION_ASSET : String = "duration_txt";
		private static const BG_ALPHA : Number = 0.6;
		private static const FADE_IN_TIME : Number = 0.2;
		
		private var controller : IController;
		private var metaVideo : MetaVideo;
		private var bg : Sprite;
		private var title : TextField;
		private var duration : TextField;
		private var loader : Loader;
		private var request : URLRequest;
		private var loaded : Boolean;

		public function PlaylistItem(controller : IController, metaVideo : MetaVideo) {
			this.controller = controller;
			this.metaVideo = metaVideo;
			
			Log.write( 'PlaylistItem ' + metaVideo.title);
			
			bg = this[BG_ASSET];
			bg.width = WIDTH;
			bg.height = HEIGHT;
			
			title = this[TITLE_ASSET];
			title.text = metaVideo.title;
			
			duration = this[DURATION_ASSET];
			duration.text = metaVideo.durationStr;
			
			loader = new Loader();
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, complete);
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, errorHandler);
			loader.contentLoaderInfo.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
			loader.contentLoaderInfo.addEventListener(AsyncErrorEvent.ASYNC_ERROR, errorHandler);
			
			hide();
			
			mouseChildren = false;
			buttonMode = true;
			useHandCursor = true;
			addEventListener(MouseEvent.CLICK, click);
			addEventListener(MouseEvent.MOUSE_OVER, show);
			addEventListener(MouseEvent.MOUSE_OUT, hide);
						
			setStyle();
		}
		
		public function load() : void {
			if (!loaded) {
				request = new URLRequest(metaVideo.thumbnailImageUrl); 
				Log.write("PlaylistItem.load * URL: "+request.url, Log.NET);
				try {
					loader.load(request);
				} catch (err : Error) {
					controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "PlaylistItem.load * " + err.message);
					fallback();
				}
				loaded = true;
			}
		}
		
		public function dispose() : void {
			loader.unloadAndStop();
			metaVideo = null;
			controller = null;
		}

		private function complete(event : Event) : void {
			loader.width = WIDTH;
			loader.height = HEIGHT;
			addChild(loader);
			loader.alpha = 0;
			GTweener.to(loader, FADE_IN_TIME, {alpha:1});
		}

		private function setStyle() : void {
			bg.transform.colorTransform = Colors.inactiveCT;
			bg.alpha = BG_ALPHA;
		}

		private function click(event : MouseEvent = null) : void {
			controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.HIDE));
			controller.playVideoAt(metaVideo.playlistIndex);
		}
		
		private function show(e : MouseEvent = null) : void {
			bg.visible = true;
			title.visible = true;
			duration.visible = true;
			loader.visible = false;
		}
	
		private function hide(e : MouseEvent = null) : void {
			bg.visible = false;
			title.visible = false;
			duration.visible = false;
			loader.visible = true;
		}

		private function errorHandler(event : Event) : void {
			controller.error(ErrorCode.PLUGIN_CUSTOM_ERROR, "PlaylistItem.errorHandler * " + event['text']);
			fallback();
		}
		
		private function fallback() : void {
			show();
			GTweener.to(loader, FADE_IN_TIME, {alpha:1});
			removeEventListener(MouseEvent.MOUSE_OVER, show);
			removeEventListener(MouseEvent.MOUSE_OUT, hide);
		}
	}
}
