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

	public static function main() {
		final intMap = [1 => 123];

		final intMap2 = intMap.copy();

		intMap.set(2, 222);

		assert(intMap.get(1) == 123);
		assert(intMap.get(2) == 222);

		assert(intMap.exists(1));
		assert(intMap.exists(2));
		assert(!intMap.exists(3));

		intMap.set(3, 333);
		assert(intMap.exists(3));
		assert(intMap.remove(3));
		assert(!intMap.remove(3));

		var sum = 0;
		for(k in intMap.keys()) {
			sum += k;
		}
		assert(sum == 3);

		final it = intMap.iterator();
		sum = 0;
		while(it.hasNext()) {
			sum += it.next();
		}
		assert(sum == (123 + 222));

		var index = 0;
		for(test in intMap.keyValueIterator()) {
			switch(index++) {
				case 0: {
					assert(test.key == 1);
					assert(test.value == 123);
				}
				case 1: {
					assert(test.key == 2);
					assert(test.value == 222);
				}
				case _: assert(false);
			}
		}

		assert(intMap.toString() == "[1 => 123, 2 => 222]");

		assert(intMap2[1] == 123);
		assert(intMap2.get(2) == null);

		intMap2.clear();

		assert(intMap2.toString() == "[]");
		assert(intMap2[1] == null);

		// Test covariance
		final _intmap: haxe.ds.IntMap<String> = [1 => "test"];
		final _map: Map<Int, String> = _intmap.copy();
		assert(_map.get(1) == "test");

		final _map2: haxe.Constraints.IMap<Int, String> = _intmap.copy();
		assert(_map2.get(1) == "test");

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}