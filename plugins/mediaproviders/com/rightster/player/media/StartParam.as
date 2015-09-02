package com.rightster.player.media {
	/**
	 * @author Rightster
	 */
	public class StartParam {
		private static var EC : String = "ec_seek";
		private static var LL : String = "ms";
		
		public static function getStartValue( val:String) : String {
			var str:String = "";
			switch(val){
				case "ec":
					str = EC;
				break;
				
				case "ll":
					str = LL;
				break;
			}
			return str;
		}
		///public static var startParam : Object = {ec : 'ec_seek', mi : '', ak : '', ll : 'fs'}; in case of back-up for start guide params
	}
}
