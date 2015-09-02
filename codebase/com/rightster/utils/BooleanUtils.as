package com.rightster.utils {
	/**
	 * @author KJR
	 */
	public class BooleanUtils {
		public static function booleanValue(value : *) : Boolean {
			if (value is Boolean) {
				return value;
			} else if (value is String) {
				return ( value.toLowerCase() == "true" || value.toLowerCase() == "1" || value.toLowerCase() == "on" || value.toLowerCase() == "yes");
			} else if (value is Number) {
				return  value == 1 ? true : false;
			}
			return false;
		}
	}
}