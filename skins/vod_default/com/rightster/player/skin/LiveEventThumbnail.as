package com.rightster.player.skin {
	import com.rightster.utils.AssetLoader;
	import com.rightster.player.events.ResizeEvent;
	import flash.system.LoaderContext;
	import com.rightster.utils.TimeUtils;
	import com.rightster.player.events.TimedPlaylistEvent;
	import flash.display.Bitmap;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	import com.rightster.player.model.MetaVideo;
	import com.rightster.player.model.ErrorCode;
	import com.gskinner.motion.GTweener;
	import flash.net.URLRequest;
	import flash.display.Sprite;
	import com.rightster.player.controller.IController;
	import flash.display.MovieClip;

	/**
	 * @author Rightster
	 */
	public class LiveEventThumbnail extends MovieClip {
		
		public static const WIDTH : Number = 149;
		public static const HEIGHT : Number = 73;
		
		private static const PADDING : Number = 2;
		private static const PADDING_WIDTH : Number = 5;
		private static const FADE_IN_TIME : Number = 0.2;
		private static const BG_ASSET : String = "bg_mc";
		private static const BG_ASSET_BORDER : String = "bg_mc_border";
		private static const TITLE_ASSET : String = "title_txt";
		private static const DESCRIPTION_ASSET : String = "desc_txt";
		private static const SYMBOL : String = ' / ';
		private static const NOW_FINISHED : String = "Now Finished";
		private static const STARTS_IN : String = "Starts in";
		private static const LIVE : String = "Live";
		
		private static const MIN_WIDTH         : Number = 520;
		private static const MIN_HEIGHT         : Number = 270;
		
		private var controller : IController;
		private var metaVideo : MetaVideo;
		private var bg : Sprite;
		private var bgBorder : Sprite;
		private var title : TextField;
		private var description : TextField;
		
		private var thumbImage : Bitmap;
		private var thumbHolder : Sprite;
		private var request : URLRequest;
		private var _enabled : Boolean = false;
		
		public function LiveEventThumbnail(controller : IController,  metaVideo : MetaVideo) {
			this.controller = controller;
			this.metaVideo = metaVideo;
			
			toggle();
			
			bgBorder = this[BG_ASSET_BORDER];
			bgBorder.width = WIDTH;
			bgBorder.height = HEIGHT;
			
			bg = this[BG_ASSET];
			bg.x = 2;
			bg.y = 2;
			bg.width = WIDTH - PADDING;
			bg.height = HEIGHT - PADDING;
			
			thumbHolder = new Sprite();
			addChild(thumbHolder);
			
			title = this[TITLE_ASSET];
			if(metaVideo != null) title.text = metaVideo.title;
			title.autoSize = TextFieldAutoSize.LEFT;
			
			description = this[DESCRIPTION_ASSET];
			
			mouseChildren = false;
			buttonMode = true;
			useHandCursor = true;
			
			if (controller.placement.playlistVersion == 2) {
				controller.addEventListener(TimedPlaylistEvent.SHOW_COUNT_DOWN, update);
				controller.addEventListener(TimedPlaylistEvent.STREAM_START, update);
				controller.addEventListener(TimedPlaylistEvent.STREAM_FINISHED, update);
			}
			controller.addEventListener(ResizeEvent.RESIZE, resize);
		}
		
		private function resize(e : ResizeEvent = null) : void {
			if(controller.width <= MIN_WIDTH || controller.height <= MIN_HEIGHT){
				_enabled = false;
			}else{
				_enabled = true;
			}
			toggle();
		}
		
		private function toggle() : void {
			super.visible = _enabled;
		}
		
		private function update(e : TimedPlaylistEvent) : void {
			if(controller.width >= MIN_WIDTH && controller.height >= MIN_HEIGHT){
				_enabled = true;
			}
			
			switch(e.type) {
				case TimedPlaylistEvent.SHOW_COUNT_DOWN :
					updateText(STARTS_IN + " "+ TimeUtils.formatSeconds(e.data.time));
				break;
				
				case TimedPlaylistEvent.STREAM_START : 
					updateText(TimeUtils.formatSeconds(Math.round(controller.getCurrentTime()), false) + SYMBOL + " " + LIVE);
					_enabled = false;
				break;
				
				case TimedPlaylistEvent.STREAM_FINISHED :
					updateText(NOW_FINISHED);
				break;
			}
			positionIcons();
			toggle();
		}
		
		public function positionIcons() : void {
			var maxLength : Number = (title.textWidth > description.textWidth) ? title.textWidth : description.textWidth;
			if(thumbImage != null){
				bgBorder.width = thumbImage.width + maxLength + (PADDING * 2) + PADDING_WIDTH * 4;
				bgBorder.height = thumbImage.height + (PADDING * 2);
				super.width = bg.width = thumbImage.width + maxLength + PADDING_WIDTH * 4;
				title.x = description.x = thumbImage.x + thumbImage.width + PADDING_WIDTH;
				title.y = ((HEIGHT - title.textHeight)/2) - PADDING_WIDTH * 2;
				description.y = ((HEIGHT - description.textHeight)/2) + PADDING_WIDTH * 2;
			}
		}
		
		public function positionIconsError() : void {
			var maxLength : Number = (title.textWidth > description.textWidth) ? title.textWidth : description.textWidth;
			
			bgBorder.width =  maxLength + (PADDING * 2) + PADDING_WIDTH * 10;
			bgBorder.height = HEIGHT + (PADDING * 2);
			super.width = bg.width =  maxLength + PADDING_WIDTH * 10;
			
			var maxGreater : String = (title.textWidth > description.textWidth) ? "title" : "desc";
			if(maxGreater == "title"){
				title.x = (bg.width - title.textWidth)/2;
				description.x = title.x;
			}else{
				description.x = (bg.width - description.textWidth)/2;
				title.x = description.x;
			}
			title.y = ((HEIGHT - title.textHeight)/2) - PADDING_WIDTH * 2;
			description.y = ((HEIGHT - description.textHeight)/2) + PADDING_WIDTH * 2;
		}
		
		private function updateText(str : String) : void {
			description.text = str;
			description.autoSize = TextFieldAutoSize.LEFT;
		}
		
		private function complete(img : Bitmap) : void {
			thumbImage = img;
			thumbImage.width = WIDTH - PADDING;
			thumbImage.height = HEIGHT - PADDING;
			thumbHolder.addChild(thumbImage);
			thumbImage.x = 2;
			thumbImage.y = 2;
			thumbHolder.alpha = 0;
			GTweener.to(thumbHolder, FADE_IN_TIME, {alpha:1});
			positionIcons();
			controller.dispatchEvent(new ResizeEvent(ResizeEvent.RESIZE));
		}
		
		private function errorHandler() : void {
			fallback();
			positionIconsError();
		}
		
		private function fallback() : void {
			GTweener.to(thumbHolder, FADE_IN_TIME, {alpha:1});
		}
		
		public function load() : void {
			if(metaVideo != null){
				request = new URLRequest(metaVideo.thumbnailImageUrl); 
				var checkPolicy : Boolean = controller.live;
				
				controller.loader.load(request, AssetLoader.TYPE_IMG, new LoaderContext(checkPolicy), false, ErrorCode.ASSET_LOADING_ERROR, "LiveEventThumbnail.load * ", complete, errorHandler);
			}else{
				positionIconsError();
			}
		}
		
		public function dispose() : void {
			controller = null;
		}
	}
}
