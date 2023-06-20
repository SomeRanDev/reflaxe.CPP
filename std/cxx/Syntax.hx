package cxx;

@:cxxStd
@:noClosure
@:noReflaxeSanitize
extern class Syntax {
	/**
		Allows for arbitrary use of `&` prefix operator in C++.
	**/
	@:nativeFunctionCode("&({arg0})")
	public static function toPointer<T>(obj: T): cxx.Ptr<T>;

	/**
		Allows for arbitrary use of `*` prefix operator in C++.
	**/
	@:nativeFunctionCode("*({arg0})")
	public static function deref(obj: cxx.Untyped): cxx.Untyped;

	/**
		Generates a C for loop.

		The arguments are filled in like this:
		```cpp
		for($start; $cond; $inc) {
			$block;
		}
		```
	**/
	@:noUsing
	public static function classicFor(start: Dynamic, cond: Dynamic, inc: Dynamic, block: Dynamic): Void;
}
