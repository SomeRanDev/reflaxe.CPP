package haxe.ds;

@:ucppStd
@:coreApi
class ObjectMap<K:{}, V> implements haxe.Constraints.IMap<K, V> {
	var m: ucpp.StdMap<K, V>;

	public function new(): Void {
		m = new ucpp.StdMap<K, V>();
	}

	public function set(key: K, value: V): Void {
		m.insert(new ucpp.std.Pair<K, V>(key, value));
	}

	public function get(key: K): Null<V> {
		return if(exists(key)) {
			m.at(key);
		} else {
			null;
		}
	}

	public function exists(key: K): Bool {
		return m.count(key) > 0;
	}

	public function remove(key: K): Bool {
		return m.erase(key) > 0;
	}

	public function keys(): Iterator<K> {
		final keys = new Array<K>();
		var it = m.begin();
		var end = m.end();
		ucpp.Syntax.classicFor(0, it != end, untyped it.increment(), untyped {
			keys.push(it.first);
		});
		return keys.iterator();
	}

	public function iterator(): Iterator<V> {
		final values = new Array<V>();
		var it = m.begin();
		var end = m.end();
		ucpp.Syntax.classicFor(0, it != end, untyped it.increment(), untyped {
			values.push(it.second);
		});
		return values.iterator();
	}

	@:runtime public inline function keyValueIterator():KeyValueIterator<K, V> {
		return new haxe.iterators.MapKeyValueIterator(this);
	}

	public function copy(): ObjectMap<K, V> {
		final result = new ObjectMap<K, V>();
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
