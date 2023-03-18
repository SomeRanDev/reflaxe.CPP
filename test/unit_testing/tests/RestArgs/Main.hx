package;

import haxe.PosInfos;

class Main {
	static var returnCode = 0;

	static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	// test haxe.Rest functions
	static function oneTwoThree(...numbers: Int) {
		// Ensure can be treated like Array<T>
		assert(numbers == [1, 2, 3]);
		assert(numbers.toString() == "[1, 2, 3]");
		
		// toArray
		final arr = numbers.toArray();
		arr.push(123);
		assert(arr.toString() == "[1, 2, 3, 123]");

		// iterator/for-loop
		var i = 1;
		for(a in numbers) {
			assert(a == i);
			i++;
		}

		// append
		assert(numbers.append(4) == [1, 2, 3, 4]);

		// prepend
		assert(numbers.prepend(0) == [0, 1, 2, 3]);
	}

	// test haxe.Rest<String>
	static function testRest(strings: haxe.Rest<String>) {
		assert(strings == ["one", "two", "three"]);
	}

	// test w/ anonymous structures
	static function testRestAny(anys: haxe.Rest<{ data: Any }>) {
		assert((anys[1].data : Array<Int>) == [0, 500, 1000]);
		assert((anys[1].data : Array<Int>)[1] == 500);
		assert((anys[1].data : Array<Int>)[2] == 1000);
	}

	// test w/ anonymous Null<T> structures
	static function testRestAny2(anys: haxe.Rest<{ data: Null<Int> }>) {
		assert(anys[0].data == 123);
		assert(anys[1].data == null);
		assert(anys[2].data == 369);
	}

	public static function main() {
		// asserts will only work with 1, 2, 3
		oneTwoThree(1, 2, 3);

		// test with String + haxe.Rest arg
		testRest("one", "two", "three");

		// extreme example using anonymous structures and Array
		testRestAny({ data: null }, { data: [0, 500, 1000] });

		// extreme example 2
		testRestAny2({ data: 123 }, { data: null }, { data: 369 });

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}