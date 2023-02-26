package;

@:native("std::any")
@:include("any", true)
@:forward.variance
abstract Any(Dynamic) {
	@:noCompletion
	@:to
	extern inline function __promote<T>():T
		return untyped __fcpp__("std::any_cast({})", this);

	@:noCompletion
	@:from
	extern inline static function __cast<T>(value:Null<T>):Any {
		if(value == null) throw "Cannot assign null to Any.";
		return cast value;
	}

	@:noCompletion
	@:include("string", true)
	extern inline function toString():String
		return "<Any(" + type().name() + ")>";

	extern inline function type(): StdTypeInfo {
		return untyped __fcpp__("{}.type()", this);
	}
}