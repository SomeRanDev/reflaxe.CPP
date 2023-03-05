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

	@:topLevel
	@:dce(Off)
	public static function main(): Int {
		// constructor
		final arr = new Array<Int>();

		// length
		assert(arr.length == 0);

		for(i in 0...3) arr.push(i + 1);

		assert(arr.length == 3);

		// concat
		assert(arr.concat([4, 5, 6]).length == 6);

		// contains
		assert(arr.contains(3));
		assert(!arr.contains(5));

		// copy
		final arr2 = arr;
		assert(arr == arr2);

		// GDScript compares Arrays by their content
		assert(arr == arr2.copy());

		// filter
		assert(arr.filter(i -> i != 1).length == 2);

		// indexOf
		final arr3 = [1, 2, 3, 4, 5];
		assert(arr3.indexOf(2) == 1);

		// insert
		arr.insert(0, 0);
		assert(arr.length == 4);
		assert(arr[0] == 0);
		assert(arr[2] == 2);

		arr.insert(-1, 4);
		assert(arr.length == 5);
		assert(arr[4] == 4);
		assert(arr[2] == 2);

		// iterator
		var total = 0;
		final it = arr.iterator();
		while(it.hasNext()) {
			total += it.next();
		}
		assert(total == 10);

		// join
		assert(arr.join(", ") == "0, 1, 2, 3, 4");

		// map
		final doubleArr = arr.map(i -> i * 2);

		// keyValueIterator
		var keyTotal = 0;
		var doubleTotal = 0;
		final kvit = doubleArr.keyValueIterator();
		while(kvit.hasNext()) {
			final o = kvit.next();
			keyTotal += o.key;
			doubleTotal += o.value;
		}
		assert(keyTotal == 10);
		assert(doubleTotal == 20);

		// pop, push
		final stack = [84, 29, 655];
		assert(stack.pop() == 655);
		assert(stack.length == 2);
		stack.push(333);
		assert(stack[2] == 333);

		// remove
		if(stack.remove(84)) {
			assert(stack.length == 2);
			assert(stack[0] == 29);
		} else {
			assert(false);
		}

		// reverse
		final ordered = [3, 6, 9, 12];
		ordered.reverse();
		assert(ordered == [12, 9, 6, 3]);

		// shift
		assert(ordered.shift() == 12);

		// slice
		final newArr = [22, 44, 66, 88];
		assert(newArr.slice(1) == [44, 66, 88]);
		assert(newArr.slice(2, 3) == [66]);
		assert(newArr.slice(-1) == [88]);
		assert(newArr.slice(-2, -1) == [66, 88]);
		assert(newArr.slice(0, 999999) == [22, 44, 66, 88]);
		assert(newArr.slice(999999, 0) == []);

		// sort
		final sortable = [2, 7, 1, 4, 0, 4];
		sortable.sort((a, b) -> a - b);
		assert(sortable == [0, 1, 2, 4, 4, 7]);

		// splice
		assert(sortable.splice(2, 1) == [2]);
		assert(sortable.splice(1, 3) == [1, 4, 4]);

		final newArr2 = [12, 24, 36, 48, 60];
		assert(newArr2.splice(-2, 1) == [48]);
		assert(newArr2.splice(-4, -1) == []);
		assert(newArr2.splice(1, 999999) == [24, 36, 60]);
		assert(newArr2.splice(999999, 0) == []);
		assert(newArr2 == [12]);

		// toString
		assert(sortable.toString() == "[0, 7]");

		// unshift
		final unfinished = [3, 4, 5];
		unfinished.unshift(2);
		unfinished.unshift(1);
		assert(unfinished == [1, 2, 3, 4, 5]);

		return returnCode;
	}
}