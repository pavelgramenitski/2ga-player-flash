package com.rightster.player.skin {
	import com.gskinner.motion.GTweener;
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.ResizeEvent;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.model.PlayerState;
	import com.rightster.player.view.Colors;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;


	/**
	 * @author Daniel
	 */
	public class PlaylistView extends Sprite {
		
		private static const BG_ASSET : String = "bg_mc";
		private static const LEFT_ASSET : String = "arrow_left_mc";
		private static const RIGHT_ASSET : String = "arrow_right_mc";
		private static const CLOSE_ASSET : String = "close_mc";
		private static const SIGN_ASSET : String = "sign_mc";
		private static const RELATED_MC : String = "related_mc";
		private static const PADDING : Number = 15;
		private static const THUMBNAIL_GAP : Number = 10;
		private static const MAX_ROWS : Number = 3;
		private static const MAX_COLUMNS : Number = 4;
		private static const SCREEN_TWEEN_TIME : Number = 0.2;
		
		private var controller : IController;
		private var bg : Sprite;
		private var thumbContainer : Sprite;
		private var left : Sprite;
		private var right : Sprite;
		private var close : Sprite;
		private var sign : Sprite;
		private var related : Sprite;
		private var items : Array = [];
		private var thumbMask : Sprite;
		private var page : uint = 0;
		private var pages : uint = 1;
		private var rows : uint;
		private var columns : uint;
		
		private var pausedBecuaseOfPlaylist:Boolean;

		public function PlaylistView(controller : IController) {
			this.controller = controller;
			
			if (!controller.placement.showPlaylist || controller.getPlaylist().length < 2) {
				return;
			}
			
			bg = this[BG_ASSET];
			bg.buttonMode = true;
			bg.useHandCursor = false;
			bg.addEventListener(MouseEvent.CLICK, closeView);
			
			sign = this[SIGN_ASSET];
			related = this[RELATED_MC];
			
			related.visible = false;
			sign.visible = false;
			
			if(controller.placement.relatedVideos){
				related.visible = true;
			}else{
				sign.visible = true;
			}
			
			left = this[LEFT_ASSET];
			left.buttonMode = true;
			left.useHandCursor = true;
			left.addEventListener(MouseEvent.CLICK, scrollLeft);
			left.addEventListener(MouseEvent.MOUSE_OVER, leftOver);
			left.addEventListener(MouseEvent.MOUSE_OUT, leftOut);
			
			right = this[RIGHT_ASSET];
			right.buttonMode = true;
			right.useHandCursor = true;
			right.addEventListener(MouseEvent.CLICK, scrollRight);
			right.addEventListener(MouseEvent.MOUSE_OVER, rightOver);
			right.addEventListener(MouseEvent.MOUSE_OUT, rightOut);
			
			close = this[CLOSE_ASSET];
			close.buttonMode = true;
			close.useHandCursor = true;
			close.addEventListener(MouseEvent.CLICK, closeView);
			close.addEventListener(MouseEvent.MOUSE_OVER, closeOver);
			close.addEventListener(MouseEvent.MOUSE_OUT, closeOut);
			
			thumbContainer = new Sprite();
			addChild(thumbContainer);
			
			thumbMask = new Sprite();
			thumbMask.graphics.beginFill(0xFF0000);
			thumbMask.graphics.drawRect(0, 0, 1, 1);
			addChild(thumbMask);
			thumbContainer.mask = thumbMask;
			
			var playlist : Array = controller.getPlaylist().playlist;
			var index : uint = controller.getPlaylistIndex();
			for (var i : int = 0; i < playlist.length; i++) {
				if (i != index) {
					var video : MetaVideo = playlist[i];
					var item : PlaylistItem = new PlaylistItem(controller, video);
					items.push(item);
					thumbContainer.addChild(item);
				}
			}
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			controller.addEventListener(PlaylistViewEvent.SHOW, onPlaylistView);
			setStyle();
			resize();
		}

		private function onPlaylistView(event : PlaylistViewEvent) : void {
			switch (controller.playerState) {
				case PlayerState.AD_PLAYING : 
				case PlayerState.VIDEO_PLAYING :
				case PlayerState.PLAYER_BUFFERING :  
					controller.pauseVideo();
					pausedBecuaseOfPlaylist = true;
				break;
			}
			loadThumbs(page);
		}
		
		private function scrollRight(event : MouseEvent) : void {
			page = (page+1) < pages ? (page + 1) : page;
			loadThumbs(page);
			var to : Number = thumbMask.x - page * (thumbMask.width + THUMBNAIL_GAP);
			GTweener.to(thumbContainer, SCREEN_TWEEN_TIME, {x:to});
		}

		private function scrollLeft(event : MouseEvent) : void {
			page = page > 0 ? (page - 1) : 0;
			loadThumbs(page);
			var to : Number = thumbMask.x - page * (thumbMask.width + THUMBNAIL_GAP);
			GTweener.to(thumbContainer, SCREEN_TWEEN_TIME, {x:to});
		}

		private function loadThumbs(_page : uint) : void {
			for (var i : int = _page * columns * rows; i < (_page+1) * columns * rows; i++) {
				if (i < items.length) {
					var item : PlaylistItem = items[i];
					item.load();
				}
			}
		}

		private function resize(event : Event = null) : void {
			rows = MAX_ROWS+1;
			columns = MAX_COLUMNS+1;
			var _w : Number;
			var _h : Number; 
			do {
				columns--;
				 _w = 4 * PADDING + left.width + right.width + columns * PlaylistItem.WIDTH + (columns-1) * THUMBNAIL_GAP; 
			} while (_w > controller.width); 
			do {
				rows--;
				 _h = 3 * PADDING + sign.height + rows * PlaylistItem.HEIGHT + (rows-1) * THUMBNAIL_GAP; 
			} while (_h > controller.height);
			
			var _x : Number = Math.round((controller.width - _w) / 2); 
			var _y : Number = Math.round((controller.height - _h) / 2); 
			
			pages = Math.ceil(items.length / (columns * rows));
			
			for (var j : int = 0; j < pages; j++) {
				for (var i : int = 0; i < (columns * rows); i++) {
					if ((i + j * (columns * rows)) < items.length) {
						var item : PlaylistItem = items[i + j * (columns * rows)];
						item.x = (i % columns) * (PlaylistItem.WIDTH + THUMBNAIL_GAP) + (j * columns * (PlaylistItem.WIDTH + THUMBNAIL_GAP));
						item.y = Math.floor(i / columns) * (PlaylistItem.HEIGHT + THUMBNAIL_GAP);
					}
				}
			}
			
			thumbMask.x = _x + 2 * PADDING + left.width;
			thumbMask.y = _y + 2 * PADDING + sign.height;
			thumbMask.width = _w - 4 * PADDING - left.width - right.width;
			thumbMask.height = _h - 3 * PADDING - sign.height;
			
			thumbContainer.x = thumbMask.x;
			thumbContainer.y = thumbMask.y;
			
			bg.width = controller.width;
			bg.height = controller.height;
			
			sign.x = thumbMask.x;
			sign.y = _y + PADDING;
			
			related.x = thumbMask.x;
			related.y = _y + PADDING;
			
			close.x = controller.width - close.width - PADDING;
			close.y = PADDING;
			
			left.x = _x + left.width / 2 + PADDING;
			left.y = left.height / 2 + sign.y + PADDING + thumbMask.height / 2;
			
			right.x = _x + _w - right.width / 2 - PADDING;
			right.y = right.height / 2 + sign.y + PADDING + thumbMask.height / 2;
		}

		private function setStyle() : void {
			bg.transform.colorTransform = Colors.baseCT;
			bg.alpha = Colors.baseAlpha;
			
			close.transform.colorTransform = Colors.primaryCT;
			left.transform.colorTransform = Colors.primaryCT;
			right.transform.colorTransform = Colors.primaryCT;
		}

		private function closeView(event : MouseEvent = null) : void {
			controller.dispatchEvent(new PlaylistViewEvent(PlaylistViewEvent.HIDE));
			if (pausedBecuaseOfPlaylist) {
				controller.playVideo();
				pausedBecuaseOfPlaylist = false;
			}
		}
		
		private function leftOver(e : MouseEvent) : void {
			left.transform.colorTransform = Colors.highlightCT;
		}
	
		private function leftOut(e : MouseEvent) : void {
			left.transform.colorTransform = Colors.primaryCT;
		}
		
		private function rightOver(e : MouseEvent) : void {
			right.transform.colorTransform = Colors.highlightCT;
		}
	
		private function rightOut(e : MouseEvent) : void {
			right.transform.colorTransform = Colors.primaryCT;
		}
		
		private function closeOver(e : MouseEvent) : void {
			close.transform.colorTransform = Colors.highlightCT;
		}
	
		private function closeOut(e : MouseEvent) : void {
			close.transform.colorTransform = Colors.primaryCT;
		}
		
		public function dispose() : void {
			for (var i : int = 0; i < items.length; i++) {
				var item : PlaylistItem = items[i];
				item.dispose();
			}
			controller.removeEventListener(ResizeEvent.RESIZE, resize);
			controller.removeEventListener(PlaylistViewEvent.SHOW, onPlaylistView);
			controller = null;
		}
	}
}
