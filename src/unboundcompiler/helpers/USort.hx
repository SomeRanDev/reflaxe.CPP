// =======================================================
// * USort
//
// Adds static extensions for Array involving sorting.
// =======================================================

package unboundcompiler.helpers;

#if (macro || ucpp_runtime)

class USort {
	public static function sorted<T>(arr: Array<T>, func: (T, T) -> Int) {
		final result = arr.copy();
		result.sort(func);
		return result;
	}

	public static function sortAlphabetically(arr: Array<String>) {
		arr.sort(alphabetic);
	}

	public static function sortedAlphabetically(arr: Array<String>): Array<String> {
		return sorted(arr, alphabetic);
	}

	public static function includeBracketOrder(a: String, b: String): Int {
		return if(a.charAt(0) == "\"" && b.charAt(0) == "<") 1;
		else if(a.charAt(0) == "<" && b.charAt(0) == "\"") -1;
		else alphabetic(a, b);
	}

	public static function alphabetic(a: String, b: String): Int {
		a = a.toLowerCase();
		b = b.toLowerCase();
		return if(a < b) -1;
		else if(a > b) 1;
		else 0;
	}
}

#end
