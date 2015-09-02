package com.rightster.player.skin {
	/**
	 * @author KJR
	 */
	public class PlaylistViewPageCalculator {
		public function calculateIndex(index : int, matrix : int) : int {
			var indexOffset : int = 1;
			var value : int;

			if (matrix > index + indexOffset) {
				value = 0;
			} else {
				value = Math.ceil((index + indexOffset) / matrix) - 1;
			}

			return value;
		}
	}
}
