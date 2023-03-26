package haxe.ds;

@:coreApi
class StringMap<T> implements haxe.Constraints.IMap<String, T> {
	var m: ucpp.std.Map<String, T>;

	public function new(): Void {
		m = new ucpp.std.Map<String, T>();
	}

	public function set(key: String, value: T): Void {
		m.insert(new ucpp.std.Pair<String, T>(key, value));
	}

	public function get(key: String): Null<T> {
		return if(exists(key)) {
			m.at(key);
		} else {
			null;
		}
	}

	public function exists(key: String): Bool {
		return m.count(key) > 0;
	}

	public function remove(key: String): Bool {
		return m.erase(key) > 0;
	}

	public function keys(): Iterator<String> {
		final keys = new Array<String>();
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

	@:runtime public inline function keyValueIterator():KeyValueIterator<String, T> {
		return new haxe.iterators.MapKeyValueIterator(this);
	}

	public function copy(): StringMap<T> {
		final result = new StringMap<T>();
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
