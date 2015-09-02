package com.rightster.player.skin {
	import flash.display.Sprite;

	/**
	 * @author KJR
	 */
	public class CaptureBorder extends Sprite {
		private static const DEFAULT_ALPHA : Number = 1;
		private static const DEFAULT_BORDER_SIZE : Number = 2;
		private var _width : Number = 100;
		private var _height : Number = 100;

		override public function get width() : Number {
			return _width;
		}

		override public function set width(w : Number) : void {
			_width = w;
			draw();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(h : Number) : void {
			_height = h;
			draw();
		}

		public function CaptureBorder() {
			draw();
			this.alpha = DEFAULT_ALPHA;
		}

		private function draw() : void {
			this.graphics.clear();
			//this.graphics.beginFill(0xff0000);
			this.graphics.lineStyle(DEFAULT_BORDER_SIZE,0xff0000);
			this.graphics.drawRect(0, 0, _width, _height);
			//this.graphics.endFill();
		}

		public function dispose() : void {
			this.graphics.clear();
		}
	}
}
