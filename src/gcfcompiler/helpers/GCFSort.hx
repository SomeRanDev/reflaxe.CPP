package gcfcompiler.helpers;

class GCFSort {
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

	public static function alphabetic(a: String, b: String): Int {
		a = a.toLowerCase();
		b = b.toLowerCase();
		return if(a < b) -1;
		else if(a > b) 1;
		else 0;
	}
}