package com.rightster.player.skin {
	import flash.text.TextFieldAutoSize;
	import com.rightster.player.events.ResizeEvent;
	import flash.text.TextField;
	import com.rightster.player.controller.IController;
	import flash.display.Sprite;

	/**
	 * @author Ravi Thapa
	 */
	public class VideoTitle extends Sprite {
		private const BG_ASSET : String = "bg_mc";
		private const BG_ASSET_MASK : String = "bg_mc_mask";
		private const TEXT_ASSET : String = "text_txt";
		private const PADDING : Number = 6;
		private const PADDING_TXT : Number = 4;
		private const BG_ALPHA : Number = 0.81;
		
		private var controller : IController;
		private var title : String;
		private var bg : Sprite;
		private var bgMask : Sprite;
		private var text : TextField;
		
		private var _width : Number = 0;
		
		override public function set width(w : Number) : void {
			_width = w;
			resize();
		}
		
		public function VideoTitle(controller : IController, title : String) {
			this.controller = controller;
			this.title = title;
			
			bg = this[BG_ASSET];
			bg.alpha = BG_ALPHA;
			
			bgMask = this[BG_ASSET_MASK];
			text = this[TEXT_ASSET];
			text.text = "";
			text.mask = bgMask;
			
			mouseChildren = false;
			controller.addEventListener(ResizeEvent.RESIZE, resize);
			resize();
		}
		
		private function resize(evt : ResizeEvent = null) : void {
			text.text = title;
			text.autoSize = TextFieldAutoSize.LEFT;
			
			text.width = text.textWidth + PADDING_TXT;
			text.height = text.textHeight + PADDING_TXT;
			
			bg.width =  text.textWidth + PADDING * 2;
			
			text.y = (bg.height - text.height)/2;
			
			if(bg.width >= _width){
				bg.width =  _width;
			}
			
			bgMask.width = bg.width - PADDING * 2;
			bgMask.x = (bg.width - bgMask.width)/2;
		}
		
		public function dispose() : void {
			width = 0;
			text.text = "";
			controller.removeEventListener(ResizeEvent.RESIZE, resize);
		}
	}
}
