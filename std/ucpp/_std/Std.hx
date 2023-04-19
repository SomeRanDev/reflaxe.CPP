package;

#if !(core_api || cross || eval)
#error "Please don't add haxe/std to your classpath, instead set HAXE_STD_PATH env var"
#end

@:ucppStd
@:includeTypeUtils
@:pseudoCoreApi
class StdImpl {
	public static function isOfType<_Value, _Type>(v: _Value, t: _Type): Bool {
		untyped __ucpp__("if constexpr(!haxe::_unwrap_class<_Type>::iscls) {
	return false;
} else if constexpr(std::is_base_of<typename haxe::_unwrap_class<_Type>::inner, typename haxe::_unwrap_mm<_Value>::inner>::value) {
	return true;
}");
		return false;
	}
}

@:ucppStd
@:pseudoCoreApi
@:headerOnly
@:headerInclude("string", true)
class Std {
	@:deprecated('Std.is is deprecated. Use Std.isOfType instead.')
	public extern inline static function is(v: Dynamic, t: Dynamic): Bool return isOfType(v, t);
	public extern inline static function isOfType<_Value, _Type>(v: _Value, t: _Type): Bool {
		return StdImpl.isOfType(v, t);
	}

	@:deprecated('Std.instance() is deprecated. Use Std.downcast() instead.')
	public extern inline static function instance<T:{}, S:T>(value: T, c: Class<S>): S return downcast(value, c);
	public extern inline static function downcast<T: {}, S: T>(value: T, c: Class<S>): Null<S> {
		// TODO: Need to add system for casting based on memory management type before implementing this.
		// I.e: use static_cast/dynamic_cast for pointers, and std::static_pointer_cast/dynamic_pointer_cast for std::shared_ptr
		// Probably not possible to cast value types??? This could get complicated.
		throw "Std.downcast is unimplemented.";
		return null;
	}

	public static function string(s: ucpp.DynamicToString): String {
		return s;
	}

	public extern inline static function int(x: Float): Int {
		return untyped __ucpp__("((int)({}))", x);
	}

	public static function parseInt(x: String): Null<Int> {
		untyped __ucpp__("try { return std::stoi({}); } catch(...) {}", x);
		return null;
	}

	public static function parseFloat(x: String): Float {
		untyped __ucpp__("try { return std::stof({}); } catch(...) {}", x);
		return Math.NaN;
	}

	public extern inline static function random(x: Int): Int {
		if(x <= 1) return 0;
		return Math.floor(Math.random() * x);
	}
}