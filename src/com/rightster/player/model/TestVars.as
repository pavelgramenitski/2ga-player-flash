package com.rightster.player.model {
	import com.rightster.utils.Log;
	
	/**
	 * @author Daniel
	 */
	public class TestVars {
		
		[Embed(source="TestVars.txt", mimeType="application/octet-stream")]
		private static const EmbeddedXML:Class;

		public static function getVars() : Object {
			var testVars : String = String(new EmbeddedXML());
			Log.write("TestVars.getVars * " + testVars, Log.DATA); 
			
			var pairs : Array = testVars.split('&');
			var obj : Object = {};
			
			for each (var pair : String in pairs) {
				obj[pair.split('=')[0]] = pair.split('=')[1];	
			}
			
			return obj;
		}
	}
}
