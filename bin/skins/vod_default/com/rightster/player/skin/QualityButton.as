package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.events.PlaybackQualityEvent;
	import com.rightster.player.view.Colors;
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.text.TextField;
	
	/**
	 * @author Daniel
	 */
	public class QualityButton extends MovieClip {
		private const BG_ASSET : String = "bg_mc";
		private const TEXT_ASSET : String = "text_txt";
		
		private var controller : IController;
		private var quality : String;
		private var bg : Sprite;
		private var text : TextField;
		private var selected : Boolean;
		
		public function QualityButton(controller : IController, quality : String) : void {
			this.controller = controller;
			this.quality = quality;
			
			bg = this[BG_ASSET];
			text = this[TEXT_ASSET];
			text.text = quality;
			
			enableButton();
			mouseChildren = false;

			setStyle();
			
			controller.addEventListener(PlaybackQualityEvent.CHANGE, qualityChange);
			qualityChange();
		}
		
		private function enableButton() : void {
			buttonMode = true;
			addEventListener(MouseEvent.MOUSE_OVER, over);
			addEventListener(MouseEvent.MOUSE_OUT, out);
			addEventListener(MouseEvent.CLICK, click);
		}
		
		private function setStyle() : void {
			text.transform.colorTransform = Colors.inactiveCT;	
			bg.transform.colorTransform = Colors.highlightCT;
			bg.alpha = 0;
		}

		private function qualityChange(e : PlaybackQualityEvent = null) : void {
			if (quality == controller.getPlaybackQuality()) {
				selected = true;
				text.transform.colorTransform = Colors.primaryCT;	
			} else {
				selected = false;
				text.transform.colorTransform = Colors.inactiveCT;	
			}
		}

		private function click(e : MouseEvent) : void {
			controller.setPlaybackQuality(quality);
		}

		private function over(e : MouseEvent) : void {
			bg.alpha = 1; 
			if (!selected) {
				text.transform.colorTransform = Colors.primaryCT;	
			}
		}

		private function out(e : MouseEvent) : void {
			bg.alpha = 0; 
			if (!selected) {
				text.transform.colorTransform = Colors.inactiveCT;	
			}
		}
	}
}
