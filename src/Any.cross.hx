package;

@:nativeName("std::any")
@:include("any", true)
@:forward.variance
@:valueType
extern abstract Any(Dynamic) {
	@:noCompletion
	@:to
	@:nativeFunctionCode("std::any_cast<{type0}>({this})")
	@:include("any", true)
	extern function __promote<T>(): T;

	@:noCompletion
	@:from
	extern inline static function __cast<T>(value: T): Any {
		return cast value;
	}

	@:noCompletion
	@:include("string", true)
	extern inline function toString(): String {
		return "<Any(" + type().name() + ")>";
	}

	extern inline function type(): ucpp.std.TypeInfo {
		return this.type();
	}
}