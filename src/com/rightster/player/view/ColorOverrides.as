package com.rightster.player.view {
	import com.rightster.player.controller.IController;
	import com.rightster.utils.Log;

	/**
	 * @author KJR
	 */
	public class ColorOverrides {
		private var controller : IController;
		private var parameterNames : Array;

		public function ColorOverrides(controller : IController, objData : Object) : void {
			this.controller = controller;
			parameterNames = ["primaryColor", "baseColor", "inactiveColor", "highlightColor", "selectedColor", "backgroundColor", "advertColor", "clockInactiveColor", "baseAlpha", "highlightAlpha", "highlightOffAlpha"];
			parse(objData);
		}

		private function parse(objData : Object) : void {
			for (var z : * in parameterNames) {
				var paramName : String = parameterNames[z];
				if (objData[paramName]) {
					assert(paramName, objData[paramName]);
				}
			}

			dispose();
		}

		private function assert(paramName : String, value : *) : void {
			var numValue : Number = (value is String) ? stringHexToInt(value) : Number(value);

			try {
				controller.colors[paramName] = numValue;
			} catch(err : Error) {
				Log.write("ColorOverrides.assert * error: " + err.message, Log.ERROR);
			}
		}

		private function stringHexToInt(str : String) : int {
			return parseInt("0x" + str.slice(1), 16);
		}

		public function dispose() : void {
			controller = null;
			parameterNames = null;
		}
	}
}
