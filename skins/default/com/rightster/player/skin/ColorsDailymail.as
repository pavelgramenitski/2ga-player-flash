package com.rightster.player.skin {
	import flash.geom.ColorTransform;
	/**
	 * @author Ravi Thapa
	 */
	public class ColorsDailymail {
		private static const PRIMARY : Number = 0xFFFFFF; 
		private static const BASE : Number = 0x363636;
		private static const INACTIVE : Number = 0x707070;
		private static const HIGHLIGHT : Number = 0x2394D2;
		private static const SELECTED : Number = 0x20648A;
		private static const BACKGROUND : Number = 0x1D1D1D;
		private static const ADVERT : Number = 0xFBBA3F;
		private static const CLOCK_INACTIVE : Number = 0x828383;
		
		private static var _primaryCT : ColorTransform;
		private static var _primaryColor : Number = PRIMARY;
		private static var _baseCT : ColorTransform;
		private static var _baseColor : Number = BASE;
		private static var _inactiveCT : ColorTransform;
		private static var _inactiveColor : Number = INACTIVE;
		private static var _highlightCT : ColorTransform;
		private static var _highlightColor : Number = HIGHLIGHT;
		private static var _baseAlpha : Number = 0.60;
		private static var _highlightAlpha : Number = 1;
		private static var _highlightOffAlpha : Number = 0;
		
		private static var _selectedCT : ColorTransform;
		private static var _selectedColor : Number = SELECTED;
		
		private static var _backgroundCT : ColorTransform;
		private static var _backgroundColor : Number = BACKGROUND;
		
		private static var _advertCT : ColorTransform;
		private static var _advertColor : Number = ADVERT;
		
		private static var _clockInactiveCT : ColorTransform;
		private static var _clockInactiveColor : Number = CLOCK_INACTIVE;
		

		static public function get primaryCT() : ColorTransform {
			return _primaryCT;
		}

		static public function get primaryColor() : Number {
			return _primaryColor;
		}

		static public function get baseCT() : ColorTransform {
			return _baseCT;
		}

		static public function get baseColor() : Number {
			return _baseColor;
		}

		static public function get inactiveCT() : ColorTransform {
			return _inactiveCT;
		}

		static public function get inactiveColor() : Number {
			return _inactiveColor;
		}

		static public function get highlightCT() : ColorTransform {
			return _highlightCT;
		}

		static public function get highlightColor() : Number {
			return _highlightColor;
		}

		static public function get baseAlpha() : Number {
			return _baseAlpha;
		}

		static public function get highlightAlpha() : Number {
			return _highlightAlpha;
		}
		
		static public function get highlightOffAlpha() : Number {
			return _highlightOffAlpha;
		}
		
		static public function get selectedCT() : ColorTransform {
			return _selectedCT;
		}
		
		static public function get selectedColor() : Number {
			return _selectedColor;
		}
		
		static public function get backgroundCT() : ColorTransform {
			return _backgroundCT;
		}
		
		static public function get backgroundColor() : Number {
			return _backgroundColor;
		}
		
		static public function get advertCT() : ColorTransform {
			return _advertCT;
		}
		
		static public function get advertColor() : Number {
			return _advertColor;
		}
		
		static public function get clockInactiveCT() : ColorTransform {
			return _clockInactiveCT;
		}
		
		static public function get clockInactiveColor() : Number {
			return _clockInactiveColor;
		}
	
		public static function initialize() : void {
			_primaryCT = new ColorTransform();
			_primaryCT.color = PRIMARY;
			_baseCT = new ColorTransform();
			_baseCT.color = BASE;
			_inactiveCT = new ColorTransform();
			_inactiveCT.color = INACTIVE;
			_highlightCT = new ColorTransform();
			_highlightCT.color = HIGHLIGHT;
			
			_selectedCT = new ColorTransform();
			_selectedCT.color = SELECTED;
			
			_backgroundCT = new ColorTransform();
			_backgroundCT.color = BACKGROUND;
			
			_advertCT = new ColorTransform();
			_advertCT.color = ADVERT;
			
			_clockInactiveCT = new ColorTransform();
			_clockInactiveCT.color = CLOCK_INACTIVE;
		}
	}
}
