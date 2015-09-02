package com.rightster.utils {
	/**
	 * @author Arun
	 */
	public class TimeUtils {
		
		public static function toSeconds(str : String) : Number {
			var starts : Array = str.split(" ");
		   	var dateArr : Array = String(starts[0]).split('-');
		   	var timeArr : Array = String(starts[1]).split(':');
		   	var UTCTime:Number = Date.UTC(dateArr[0], (dateArr[1] - 1), dateArr[2], timeArr[0], timeArr[1], timeArr[2], 0)/1000;
		   	return(UTCTime);
		}
		
		public static function formatSeconds(seconds : Number, showHours : Boolean = true) : String {
			var hr : Number = Math.floor(seconds / 3600);
			var min : Number = Math.floor((seconds % 3600)/60);
			var sec : Number = Math.floor(seconds % 60);
			var res : String = sec < 10 ? (':0' + sec) : (':' + sec);
			if (showHours) {
				res = min < 10 ? (':0' + min + res) : (':' + min + res);
				res = hr + res;
			} else {
				res = min + res;
			}
				
			return res;
		}
	}
}
