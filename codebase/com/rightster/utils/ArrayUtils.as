package com.rightster.utils {
	import flash.utils.ByteArray;
	/**
	 * @author Ken Rutherford
	 */
	public class ArrayUtils {
		
		static public function removeAll(arr : Array) : void {
			for (var i:int = 0; i< arr.length; i++ ){
				removeAt(arr, i);
			}
		}
		
		static public function removeAt(array : Array, index : int) : Array {
			array.splice(index, 1) ;
			return array ;
		}
		
		
		// compare single dimensional array
		static public function areEqual(array1 : Array, array2 : Array) : Boolean {
			if (array1.length != array2.length) {
				return false;
			} else {
				for (var i : int = 0, j : int = array1.length; i < j; i += 1) {
					if (array1[i] != array2[i]) {
						return false;
					}
				}
				return true;
			}
		}

		static public function contains(ar : Array, value : Object) : Boolean {
			return (indexOf(ar, value) > -1) ;
		}

		static public function indexOf(ar : Array, value : Object, startIndex : * = null, count : * = null) : int {
			var l : int = ar.length ;
			if (isNaN(startIndex) ) startIndex = 0 ;

			if (isNaN(count)) {
				count = ar.length - startIndex ;
			}

			if (startIndex < 0 || startIndex > l) {
				trace("ArrayUtil.indexOf : 'startIndex' must be between 0 and " + l + ".");
			}

			if (count < 0 || count > (l - startIndex)) {
				trace("ArrayUtil.indexOf : 'count' must be between 'startIndex' and the array size -1.") ;
			}

			for (var i : int = 0; startIndex < l; startIndex++ , i++) {
				if (ar[startIndex] == value) {
					return startIndex ;
				}
				if (i == count) {
					break ;
				}
			}
			return -1 ;
		}

		static public function pierce(ar : Array, index : int, flag : Boolean) : * {
			var item : * = ar[index] ;
			ar.splice(index, 1) ;
			return (flag) ? ar : item ;
		}

		static public function randomize(ar : Array) : Array {
			var tmp : Array = [] ;
			var len : int = ar.length;
			var index : int = len - 1 ;
			for (var i : int = 0; i < len; i++) {
				tmp.push(pierce(ar, Math.round(Math.random() * index), false));
				index-- ;
			}
			while (--len > -1) {
				ar[len] = tmp[len] ;
			}
			return ar ;
		}

		static public function clone(source : Object) : * {
			var ba:ByteArray = new ByteArray();
			ba.writeObject(source);
			ba.position = 0;
			return(ba.readObject());
		}

		static public function toString(ar : Array, strJoin : String) : String {
			return ar.join(strJoin || ",") ;
		}
	}
}