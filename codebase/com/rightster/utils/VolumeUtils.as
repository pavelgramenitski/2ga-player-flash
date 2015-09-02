package com.rightster.utils {
	/**
	 * @author Rightster
	 */
	public class VolumeUtils {
		private static const FULL_VOLUME : Number = 100;
		
		public static function formatToCodeLevel ( num : Number) : Number {
			return num / FULL_VOLUME;
		}
		
		public static function formatToUserLevel ( num : Number) : Number {
			return num * FULL_VOLUME;
		}
		
		public static function easeInQuad (t : Number, b : Number = 0, c : Number = 100, d :Number = 100) : Number {
			t /= d;
			return c*t*t + b;
		}
		
		public static function reverseEiQ (x : Number, b : Number = 0, c : Number = 100, d :Number = 100) : Number {
			return Math.sqrt((x - b) / c) * d;
		}
	}
}
