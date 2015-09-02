package com.rightster.utils {
	/**
	 * @author Ken Rutherford
	 */
	public class Delegate {
		
		public static function create(fnc:Function, ... args):Function {
			return function(... theArgs):void {	
				fnc.apply(this,theArgs.concat(args));
			};
		}
	}
}
