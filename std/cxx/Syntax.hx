package cxx;

@:cxxStd
@:noClosure
@:noReflaxeSanitize
extern class Syntax {
	/**
		Assign this to a variable declaration to have the
		variable be generated without a value.

		A type MUST be provided.

		For example:
		```haxe
		var a: cxx.Value<MyClass> = cxx.Syntax.NoAssign;
		var a: cxx.Value<MyClass> = cxx.Syntax.NoAssign(123);
		```

		Converts to:
		```cpp
		MyClass a;
		MyClass b(123);
		```
	**/
	@:uncompilable
	public static var NoAssign: cxx.Untyped.UntypedCallable;

	/**
		Allows assignment to any expression.

		For example, this is invalid Haxe:
		```haxe
		someDataStruct.get(value) = 123;
		```

		But there may be some C++ methods that return mutable
		references that can be assigned to. So this function
		generates C++ in the form of `EXPR = ARG` to allow this:
		```haxe
		using cxx.Syntax;

		// ---

		// Generates someDataStruct.get(value) = 123;
		someDataStruct.get(value).assign(123);
		```
	**/
	@:nativeFunctionCode("{arg0} = {arg1}")
	public static function assign<T, U>(self: T, value: U): Void;

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
