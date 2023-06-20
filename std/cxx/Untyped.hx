package cxx;

/**
	This type is used to represent an any type with C++
	extern signatures. If the type is compiled it throws
	an error, so users must declare the type themselves
	when using or storing in a variable.

	The reason to use this type instead of `Dynamic` or
	`Any` is because using those types may trigger unnecessary
	dynamic wrapping to be generated.

	`Untyped` guarantees nothing will be generated.
**/
@:uncompilable
extern abstract Untyped(Dynamic) from Dynamic to Dynamic {
}

@:uncompilable
@:callable
extern abstract UntypedCallable(Dynamic) from Dynamic to Dynamic {
}
