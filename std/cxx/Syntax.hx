package cxx;

@:cxxStd
@:noClosure
@:noReflaxeSanitize
extern class Syntax {
	public static function classicFor(start: Dynamic, cond: Dynamic, inc: Dynamic, block: Dynamic): Void;

	@:nativeFunctionCode("&({arg0})")
	public static function toPointer<T>(obj: T): cxx.Ptr<T>;
}
