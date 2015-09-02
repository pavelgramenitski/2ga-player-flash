package com.rightster.player.view {
	import flash.geom.ColorTransform;

	/**
	 * @author KJR
	 */
	public interface IColors {
		function get primaryCT() : ColorTransform ;

		function get primaryColor() : Number;

		function set primaryColor(value : Number) : void ;

		function get baseCT() : ColorTransform;

		function get baseColor() : Number ;

		function set baseColor(value : Number) : void;

		function get baseAlpha() : Number;

		function set baseAlpha(value : Number) : void;

		function get inactiveCT() : ColorTransform ;

		function get inactiveColor() : Number ;

		function set inactiveColor(value : Number) : void;

		function get highlightCT() : ColorTransform ;

		function get highlightColor() : Number ;

		function set highlightColor(value : Number) : void;

		function get highlightAlpha() : Number ;

		function set highlightAlpha(value : Number) : void;

		function get highlightOffAlpha() : Number ;

		function set highlightOffAlpha(value : Number) : void;

		function get selectedCT() : ColorTransform;

		function get selectedColor() : Number ;

		function set selectedColor(value : Number) : void;

		function get backgroundCT() : ColorTransform;

		function get backgroundColor() : Number ;

		function set backgroundColor(value : Number) : void;

		function get overlayCT() : ColorTransform;

		function get overlayColor() : Number ;

		function set overlayColor(value : Number) : void;

		function get overlayAlpha() : Number;

		function set overlayAlpha(value : Number) : void;

		function get advertCT() : ColorTransform ;

		function get advertColor() : Number;

		function set advertColor(value : Number) : void;

		function get clockInactiveCT() : ColorTransform ;

		function get clockInactiveColor() : Number ;

		function set clockInactiveColor(value : Number) : void;

		function initialize() : void ;
	}
}
