import haxe.iterators.ArrayKeyValueIterator;

@:cxxStd
@:pseudoCoreApi
@:dontGenerateDynamic
@:unreflective
@:filename("HxArray")
class HxArray {
	public static function concat<T>(a: Array<T>, other: Array<T>): Array<T> {
		final result = a.copy();
		for(o in other) {
			result.push(o);
		}
		return result;
	}

	public static function join<T>(a: Array<T>, sep: String): String {
		var result = "";
		for(i in 0...a.length) {
			if(i > 0) result += sep;
			result += Std.string(a[i]);
		}
		return result;
	}

	public static function slice<T>(a: Array<T>, pos: Int, end: Null<Int> = null): Array<T> {
		// if pos is negative, its value is calculated from the end of the array
		if(pos < 0) pos += a.length;

		// if outside bounds, return an empty array
		if(pos < 0 || pos >= a.length) return [];

		// if end is not defined or exceeds the end of the array, set to the end
		if(end == null || end > a.length) end = a.length;
		else {
			// if end is negative, its value is calculated from the end of the array
			if(end < 0) end += a.length;

			// if outside bounds, return an empty array
			if(end <= pos) return [];
		}

		final result = new Array<T>();
		for(i in pos...end) {
			if(i >= 0 && i < a.length) {
				result.push(a[i]);
			}
		}
		return result;
	}

	public static function splice<T>(a: cxx.Ref<Array<T>>, pos: Int, len: Int): Array<T> {
		// if pos is negative, its value is calculated from the end of the array
		if(pos < 0) pos += a.length;

		// return an empty array if bounds do not make sense
		if(pos < 0 || pos > a.length) return [];
		if(len < 0) return [];

		// if pos + len exceeds the length of the array, affect all elements after pos
		if(pos + len > a.length) len = a.length - pos;

		final beginIt: cxx.Auto = untyped a.begin();
		final startIt: cxx.Auto = beginIt + pos;
		final endIt: cxx.Auto = beginIt + pos + len;

		final result = new Array<T>();
		for(i in pos...(pos + len)) {
			if(i >= 0 && i < a.length) {
				result.push(a[i]);
			}
		}

		untyped a.erase(startIt, endIt);

		return result;
	}

	public static function insert<T>(a: cxx.Ref<Array<T>>, pos: Int, x: T) {
		if(pos < 0) {
			final it: cxx.Auto = untyped a.end() + pos + 1;
			untyped a.cppInsert(it, x);
		} else {
			final it: cxx.Auto = untyped a.begin() + pos;
			untyped a.cppInsert(it, x);
		}
	}

	public static function indexOf<T>(a: Array<T>, x: T, fromIndex: Int  = 0): Int {
		final it: cxx.Auto = untyped __cpp__("std::find({0}, {1}, {2})", a.begin(), a.end(), x);
		return if(untyped it != a.end()) {
			cxx.Stdlib.ccast(untyped it - a.begin());
		} else {
			-1;
		}
	}

	public static function map<T, S>(a: Array<T>, f: (T) -> S): Array<S> {
		return [for (v in a) f(v)];
	}

	public static function filter<T>(a: Array<T>, f: (T) -> Bool): Array<T> {
		return [for (v in a) if (f(v)) v];
	}

	public static function toString<T>(a: Array<T>): String {
		var result = "[";
		for(i in 0...a.length) {
			result += (i != 0 ? ", " : "") + Std.string(a[i]);
		}
		return result + "]";
	}
}

@:cxxStd
@:coreApi
@:nativeName("std::deque")
@:include("deque", true)
@:valueEquality
@:filename("HxArray")
@:dynamicCompatible
@:allow(HxArray)
extern class Array<T> {
	// ----------------------------
	// Haxe String Functions
	// ----------------------------

	// ----------
	// constructor
	public extern function new(): Void;

	// ----------
	// @:nativeName
	@:nativeName("size()")
	@:redirectType("length_type")
	@:dynamicAccessors("default", "never")
	var length(default, null): Int;

	@:nativeName("push_front")
	public function unshift(x: T): Void;

	@:nativeName("insert")
	private function cppInsert(pos: Int, x: T): Void;

	public function resize(len: Int): Void;

	public function lastIndexOf(x: T, ?fromIndex: Int): Int;

	// ----------
	// @:runtime inline
	@:runtime public inline function push(x: T): Int {
		untyped this.push_back(x);
		return length;
	}

	@:runtime public inline function pop(): Null<T> {
		final result = untyped this.back();
		untyped this.pop_back();
		return result;
	}

	@:runtime public inline function reverse(): Void {
		untyped __include__("algorithm", true);
		untyped __cpp__("std::reverse({0}, {1})", this.begin(), this.end());
	}

	@:runtime public inline function shift(): Null<T>  {
		final result = untyped this.front();
		untyped this.pop_front();
		return result;
	}

	@:runtime public inline function sort(f: (T, T) -> Int): Void {
		untyped __include__("algorithm", true);
		untyped __cpp__("std::sort({0}, {1}, {2})", this.begin(), this.end(), function(a, b) {
			return f(a, b) < 0;
		});
	}

	@:runtime public inline function remove(x: T): Bool {
		final index = this.indexOf(x);
		if(index < 0) {
			return false;
		}
		untyped this.erase(this.begin() + index);
		return true;
	}

	@:runtime @:pure public inline function contains(x: T) : Bool {
		untyped __include__("algorithm", true);
		return untyped __cpp__("(std::find({0}, {1}, {2}) != {3})", this.begin(), this.end(), x, this.end());
	}

	@:runtime public inline function copy(): Array<T> {
		final result = [];
		for(obj in this) {
			result.push(obj);
		}
		return result;
	}

	@:runtime public inline function iterator(): haxe.iterators.ArrayIterator<T> {
		return new haxe.iterators.ArrayIterator(this);
	}

	@:pure @:runtime public inline function keyValueIterator() : ArrayKeyValueIterator<T> {
		return new ArrayKeyValueIterator(this);
	}

	// ----------
	// HxArray
	@:runtime public inline function concat(a:Array<T>):Array<T> {
		return HxArray.concat(this, a);
	}

	@:runtime public inline function join(sep: String): String {
		return HxArray.join(this, sep);
	}

	@:runtime public inline function slice(pos: Int, ?end: Int): Array<T> {
		return HxArray.slice(this, pos, end);
	}

	@:runtime public inline function splice(pos: Int, len: Int): Array<T> {
		return HxArray.splice(this, pos, len);
	}

	@:runtime public inline function toString(): String {
		return HxArray.toString(this);
	}

	@:runtime public inline function insert(pos: Int, x: T): Void {
		HxArray.insert(this, pos, x);
	}

	@:runtime public inline function indexOf(x: T, fromIndex: Int = 0): Int {
		return HxArray.indexOf(this, x, fromIndex);
	}

	@:runtime public inline function map<S>(f: (T) -> S): Array<S> {
		return HxArray.map(this, f);
	}

	@:runtime public inline function filter(f: (T) -> Bool): Array<T> {
		return HxArray.filter(this, f);
	}

	// ----------
	// Redirects
	@:unusable
	@:dontGenerateDynamic
	@:noCompletion
	private var length_type: cxx.num.UInt32;
}