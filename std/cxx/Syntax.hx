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
		Uses `delete` operator on the argument.
	**/
	@:nativeFunctionCode("delete ({arg0})")
	public static function delete(obj: cxx.Untyped): cxx.Untyped;

	/**
		Bypass Haxe's typer and treat the object as a `bool` to use
		its C++ `operator bool()` function.
	**/
	@:nativeFunctionCode("({arg0})")
	public static function boolOp(obj: cxx.Untyped): Bool;

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
	public static function classicFor(start: cxx.Untyped, cond: cxx.Untyped, inc: cxx.Untyped, block: cxx.Untyped): Void;
}
