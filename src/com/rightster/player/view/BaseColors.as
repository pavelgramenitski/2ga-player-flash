package com.rightster.player.view {
	import com.rightster.player.view.IColors;

	import flash.geom.ColorTransform;

	/**
	 * @author KJR
	 */
	public class BaseColors implements IColors {
		private const PRIMARY : Number = 0xFFFFFF;
		private const BASE : Number = 0x2b2b2b;
		private const OVERLAY : Number = 0x2b2b2b;
		private const INACTIVE : Number = 0x707070;
		private const HIGHLIGHT : Number = 0x0092d4;
		private const SELECTED : Number = 0x20648A;
		private const BACKGROUND : Number = 0x1D1D1D;
		private const ADVERT : Number = 0xFBBA3F;
		private const CLOCK_INACTIVE : Number = 0x828383;
		private const BASE_ALPHA : Number = 0.6;
		private const OVERLAY_ALPHA : Number = 0.8;
		private const HIGHLIGHT_ALPHA : Number = 1;
		private const HIGHLIGHT_OFF_ALPHA : Number = 0;
		private var _primaryCT : ColorTransform;
		private var _primaryColor : Number ;
		private var _baseCT : ColorTransform;
		private var _baseColor : Number ;
		private var _overlayCT : ColorTransform;
		private var _overlayColor : Number ;
		private var _inactiveCT : ColorTransform;
		private var _inactiveColor : Number;
		private var _highlightCT : ColorTransform;
		private var _highlightColor : Number ;
		private var _baseAlpha : Number;
		private var _overlayAlpha : Number;
		private var _highlightAlpha : Number ;
		private var _highlightOffAlpha : Number ;
		private var _selectedCT : ColorTransform;
		private var _selectedColor : Number;
		private var _backgroundCT : ColorTransform;
		private var _backgroundColor : Number;
		private var _advertCT : ColorTransform;
		private var _advertColor : Number;
		private var _clockInactiveCT : ColorTransform;
		private var _clockInactiveColor : Number;
		private var initialized : Boolean;

		public function initialize() : void {
			if (!initialized) {
				// colors
				_primaryColor = PRIMARY;
				_baseColor = BASE;
				_overlayColor = OVERLAY;
				_inactiveColor = INACTIVE;
				_highlightColor = HIGHLIGHT;
				_selectedColor = SELECTED;
				_backgroundColor = BACKGROUND;
				_advertColor = ADVERT;
				_clockInactiveColor = CLOCK_INACTIVE;

				// alphas
				_baseAlpha = BASE_ALPHA;
				_overlayAlpha = OVERLAY_ALPHA;
				_highlightAlpha = HIGHLIGHT_ALPHA;
				_highlightOffAlpha = HIGHLIGHT_OFF_ALPHA;

				// color transforms
				_primaryCT = new ColorTransform();
				_primaryCT.color = PRIMARY;

				_baseCT = new ColorTransform();
				_baseCT.color = BASE;

				_overlayCT = new ColorTransform();
				_overlayCT.color = OVERLAY;

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

				initialized = true;
			}
		}

		public function get primaryCT() : ColorTransform {
			return _primaryCT;
		}

		public function get primaryColor() : Number {
			return _primaryColor;
		}

		public function get baseCT() : ColorTransform {
			return _baseCT;
		}

		public function get baseColor() : Number {
			return _baseColor;
		}

		public function get overlayCT() : ColorTransform {
			return _overlayCT;
		}

		public function get overlayColor() : Number {
			return _overlayColor;
		}

		public function get inactiveCT() : ColorTransform {
			return _inactiveCT;
		}

		public function get inactiveColor() : Number {
			return _inactiveColor;
		}

		public function get highlightCT() : ColorTransform {
			return _highlightCT;
		}

		public function get highlightColor() : Number {
			return _highlightColor;
		}

		public function get baseAlpha() : Number {
			return _baseAlpha;
		}

		public function get overlayAlpha() : Number {
			return _overlayAlpha;
		}

		public function get highlightAlpha() : Number {
			return _highlightAlpha;
		}

		public function get highlightOffAlpha() : Number {
			return _highlightOffAlpha;
		}

		public function get selectedCT() : ColorTransform {
			return _selectedCT;
		}

		public function get selectedColor() : Number {
			return _selectedColor;
		}

		public function get backgroundCT() : ColorTransform {
			return _backgroundCT;
		}

		public function get backgroundColor() : Number {
			return _backgroundColor;
		}

		public function get advertCT() : ColorTransform {
			return _advertCT;
		}

		public function get advertColor() : Number {
			return _advertColor;
		}

		public function get clockInactiveCT() : ColorTransform {
			return _clockInactiveCT;
		}

		public function get clockInactiveColor() : Number {
			return _clockInactiveColor;
		}

		public function set primaryColor(value : Number) : void {
			_primaryColor = value;
			_primaryCT.color = _primaryColor;
		}

		public function set baseColor(value : Number) : void {
			_baseColor = value;
			_baseCT.color = _baseColor;
		}

		public function set overlayColor(value : Number) : void {
			_overlayColor = value;
			_overlayCT.color = _overlayColor;
		}

		public function set inactiveColor(value : Number) : void {
			_inactiveColor = value;
			_inactiveCT.color = value;
		}

		public function set highlightColor(value : Number) : void {
			_highlightColor = value;
			_highlightCT.color = _highlightColor;
		}

		public function set selectedColor(value : Number) : void {
			_selectedColor = value;
			_selectedCT.color = _selectedColor;
		}

		public function set backgroundColor(value : Number) : void {
			_backgroundColor = value;
			_backgroundCT.color = _backgroundColor;
		}

		public function set advertColor(value : Number) : void {
			_advertColor = value;
			_advertCT.color = _advertColor;
		}

		public function set clockInactiveColor(value : Number) : void {
			_clockInactiveColor = value;
			_clockInactiveCT.color = _clockInactiveColor;
		}

		public function set baseAlpha(value : Number) : void {
			_baseAlpha = value;
		}

		public function set overlayAlpha(value : Number) : void {
			_overlayAlpha = value;
		}

		public function set highlightAlpha(value : Number) : void {
			_highlightAlpha = value;
		}

		public function set highlightOffAlpha(value : Number) : void {
			_highlightOffAlpha = value;
		}
	}
}
