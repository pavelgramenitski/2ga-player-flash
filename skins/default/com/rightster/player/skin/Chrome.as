package com.rightster.player.skin {
	import com.rightster.player.controller.IController;
	import com.rightster.player.view.IColors;
	import com.rightster.utils.Log;

	import flash.display.Sprite;

	/**
	 * @author KJR
	 */
	public class Chrome extends Sprite {
		private var controller : IController;
		private var colorScheme : IColors;
		private var bg : ColorBackground;
		private var _width : Number = 44;
		private var _height : Number = 31;

		public function Chrome(controller : IController) : void {
			this.controller = controller;
			this.colorScheme = controller.colors;
			bg = new ColorBackground(colorScheme.baseCT, colorScheme.baseAlpha,false,false);
			addChild(bg);
			layout();
			
		}

		override public function get width() : Number {
			return _width;
		}

		override public function set width(value : Number) : void {
			_width = value;
			// super.width = _width;
			layout();
		}

		override public function get height() : Number {
			return _height;
		}

		override public function set height(value : Number) : void {
			_height = value;
			//logsuper.height = _height;
			layout();
		}

//		public function refresh() : void {
//			Log.write("Chrome:refresh");
//			layout();
//		}

		private function layout() : void {
			bg.width = _width;
			bg.height = _height;
		}

		

		public function dispose() : void {
			bg.dispose();
			bg = null;
			colorScheme = null;
			controller = null;
		}
	}
}
