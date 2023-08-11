package cxx;

/**
	This type allows for C++ to be injected directly for the type.

	```haxe
	final num: cxx.CppType<"uint_8"> = 123;
	```
**/
extern class CppType<@:const CppTypeCode: String> {
}
