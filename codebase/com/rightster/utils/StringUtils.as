package com.rightster.utils {
	/**
	 * @author KJR
	 */
	public class StringUtils {
		/*
		 * Trim Whitespace From the Beginning and End of a String 
		 */
		public static function trim(value : String) : String {
			if (value == null) {
				return "";
			}
			return value.replace(/^\s+|\s+$/g, "");
		}

		public static function decodeURIString(value : String) : String {
			var str : String;
			try {
				str = String(decodeURIComponent(value));
			} catch(err : Error) {
				Log.write("XML parse error : " + err.message);
			}
			return str;
		}

		public static function stringToBoolean(str : String) : Boolean {
			return ( str.toLowerCase() == "true" || str.toLowerCase() == "1");
		}

		public static function replace(str : String, search : String, replace : String) : String {
			return str.split(search).join(replace) ;
		}

		public static function trimTrailing(str : String, token : String) : String {
			var regExp : RegExp = new RegExp(token, "$/g");

			if (str == null) {
				return "";
			}
			return str.replace(regExp, "");
		}
	}
}
