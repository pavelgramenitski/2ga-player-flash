package com.rightster.player.skin {
	import com.rightster.player.events.PlayerStateEvent;
	import com.rightster.player.model.PlayerState;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextField;
	import com.rightster.player.events.ResizeEvent;
	import flash.events.MouseEvent;
	import com.rightster.player.view.Colors;
	import flash.display.Sprite;
	import com.rightster.player.controller.IController;
	import flash.display.MovieClip;

	/**
	 * @author Rightster
	 */
	public class PlayListVideoSelector extends MovieClip {
		
		private static const BG_ASSET : String = "bg_mc";
		private static const TEXT_TITLE	 : String = "text_title";
		private static const TEXT_TITLE_PADDING	 : Number = 12;
		
		private var controller : IController;
		private var _width : Number;
		private var bgAsset : Sprite;
		private var prevButton : PlayListPrevButton;
		private var nextButton : PlayListNextButton;
		private var textTitleDisplay : TextField;
		private var _enabled : Boolean = false;
		private var isClicked: Boolean;
		
		override public function set width(n : Number) : void {
			_width = n;
			bgAsset.width = _width;
		}
		
		override public function get width() : Number {
			return _width;
		}
		
		public function PlayListVideoSelector(controller : IController) {
			this.controller = controller;
			
			_enabled = false;
			toggle();
			
			bgAsset = this[BG_ASSET];
			prevButton = new PlayListPrevButton(controller);
			nextButton = new PlayListNextButton(controller);
			textTitleDisplay = this[TEXT_TITLE];
			
			this.addChild(prevButton);
			this.addChild(nextButton);
			
			prevButton.addEventListener(MouseEvent.CLICK, playPrevVideo);
			nextButton.addEventListener(MouseEvent.CLICK, playNextVideo);
			
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			controller.addEventListener(PlayerStateEvent.CHANGE, stateChange);
			setStyle();
		}
		
		private function toggle() : void {
			super.visible = _enabled;
		}
		
		private function stateChange(e : PlayerStateEvent = null) : void {
			if(controller != null){
				switch (controller.playerState) {
					case PlayerState.VIDEO_READY :
					default:
						resize();
					break;
				}
			}
		}
		
		private function resize(e : ResizeEvent = null) : void {
			if(controller != null){
				if (controller.getPlaylist().length > 1) {
					_enabled = true;
					toggle();
				} else {
					_enabled = false;
					toggle();
				}
				
				nextButton.x = _width - nextButton.width;
				var maxWidth : Number = _width - (prevButton.width * 2 + TEXT_TITLE_PADDING);
				var txtTitle : String = String(controller.video.title);
				textTitleDisplay.text = txtTitle;
				if(textTitleDisplay.textWidth > maxWidth){
					var avg : Number = Number(textTitleDisplay.textWidth/txtTitle.length);
					var finalAvg : Number = Number(maxWidth/avg);
					textTitleDisplay.text = txtTitle.substring(0,finalAvg);
				}
				textTitleDisplay.autoSize = TextFieldAutoSize.LEFT;
			}
		}
		
		private function setStyle() : void {
			bgAsset.transform.colorTransform = Colors.inactiveCT;
			bgAsset.alpha = Colors.baseAlpha;
		}
		
		private function playNextVideo(event : MouseEvent) : void {
			if(!isClicked) controller.nextVideo();
			isClicked = true;
		}
		
		private function playPrevVideo(event : MouseEvent) : void {
			if(!isClicked) controller.previousVideo();
			isClicked = true; 
		}
		
		public function dispose() : void {
			textTitleDisplay.text = "";
			
			prevButton.removeEventListener(MouseEvent.CLICK, playPrevVideo);
			nextButton.removeEventListener(MouseEvent.CLICK, playNextVideo);
			
			prevButton.dispose();
			this.removeChild(prevButton);
			prevButton = null;
			
			nextButton.dispose();
			this.removeChild(nextButton);
			nextButton = null;
			
			
			controller.removeEventListener(ResizeEvent.RESIZE, resize);
			controller.removeEventListener(PlayerStateEvent.CHANGE, stateChange);
			
			controller = null;
		}
	}
}
