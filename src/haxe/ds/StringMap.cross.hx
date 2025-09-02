package haxe.ds;

@:cxxStd
@:haxeStd
@:coreApi
class StringMap<T> implements haxe.Constraints.IMap<String, T> {
	var m: cxx.StdMap<String, T>;

	public function new(): Void {
		m = new cxx.StdMap<String, T>();
	}

	public function set(key: String, value: T): Void {
		m.insert(new cxx.std.Pair<String, T>(key, value));
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
		cxx.Syntax.classicFor(untyped _, it != end, untyped it.increment(), untyped {
			keys.push(it.first);
		});
		return keys.iterator();
	}

	public function iterator(): Iterator<T> {
		final values = new Array<T>();
		var it = m.begin();
		var end = m.end();
		cxx.Syntax.classicFor(untyped _, it != end, untyped it.increment(), untyped {
			values.push(it.second);
		});
		return values.iterator();
	}

	@:requireMemoryManagement(SharedPtr)
	@:requireReturnTypeHasConstructor
	@:runtime public inline function keyValueIterator(): KeyValueIterator<String, T> {
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

	#if haxe5
	public function size(): Int {
		return m.size();
	}
	#end
}
