package haxe.ds;

@:coreApi
class IntMap<T> implements haxe.Constraints.IMap<Int, T> {
	var m: ucpp.std.Map<Int, T>;

	public function new(): Void {
		m = new ucpp.std.Map<Int, T>();
	}

	public function set(key: Int, value: T): Void {
		m.insert(new ucpp.std.Pair<Int, T>(key, value));
	}

	public function get(key: Int): Null<T> {
		return if(exists(key)) {
			m.at(key);
		} else {
			null;
		}
	}

	public function exists(key: Int): Bool {
		return m.count(key) > 0;
	}

	public function remove(key: Int): Bool {
		return m.erase(key) > 0;
	}

	public function keys(): Iterator<Int> {
		final keys = new Array<Int>();
		var it = m.begin();
		var end = m.end();
		ucpp.Syntax.classicFor(0, it != end, untyped it.increment(), untyped {
			keys.push(it.first);
		});
		return keys.iterator();
	}

	public function iterator(): Iterator<T> {
		final values = new Array<T>();
		var it = m.begin();
		var end = m.end();
		ucpp.Syntax.classicFor(0, it != end, untyped it.increment(), untyped {
			values.push(it.second);
		});
		return values.iterator();
	}

	@:runtime public inline function keyValueIterator():KeyValueIterator<Int, T> {
		return new haxe.iterators.MapKeyValueIterator(this);
	}

	public function copy(): IntMap<T> {
		final result = new IntMap<T>();
		for(k in keys()) {
			result.set(k, get(k));
		}
		return result;
	}

	public function toString(): String {
		var result = "[";
		var first = true;
		for(key => value in this) {
			result += (first ? "" : ", ") + (Std.string(key) + " => " + Std.string(value));
			if(first) first = false;
		}
		return result + "]";
	}

	public function clear(): Void {
		m.clear();
	}
}
