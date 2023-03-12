package;

#if !(core_api || cross || eval)
#error "Please don't add haxe/std to your classpath, instead set HAXE_STD_PATH env var"
#end

@:headerCode("template <typename T, typename = std::string>
struct HasToString : std::false_type { };

template <typename T>
struct HasToString <T, decltype((void) T::toString, 0)> : std::true_type { };")
@:pseudoCoreApi
@:headerOnly
@:headerInclude("type_traits", true)
@:headerInclude("string", true)
class Std {
	@:deprecated('Std.is is deprecated. Use Std.isOfType instead.')
	public extern inline static function is(v: Dynamic, t: Dynamic): Bool return isOfType(v, t);
	public extern inline static function isOfType(v: Dynamic, t: Dynamic): Bool {
		return false;
	}

	@:deprecated('Std.instance() is deprecated. Use Std.downcast() instead.')
	public extern inline static function instance<T:{}, S:T>(value: T, c: Class<S>): S return downcast(value, c);
	public extern inline static function downcast<T: {}, S: T>(value: T, c: Class<S>): S {
		return cast value;
	}

	public static function string<T>(s: T): String {
		untyped __ucpp__("if constexpr(haxe::optional_info<T>::isopt) {
	if(s.has_value()) {
		return Std::string({}.value());
	} else {
		return \"null\";
	}
} else if constexpr(std::is_integral_v<T>) {
	return std::to_string({});
} else if constexpr(std::is_convertible<T, std::string>::value) {
	return std::string({});
} else if constexpr(HasToString<T>::value) {
	return {}.toString();
}", s, s, s, s);
		return "<unknown(size:" + ucpp.Stdlib.intToString(ucpp.Stdlib.sizeof(s)) + ")>";
	}

	public extern inline static function int(x: Float): Int {
		return untyped __ucpp__("((int){})", x);
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