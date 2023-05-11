package cxxcompiler.config;

enum abstract Define(String) from String to String {
	/**
		-D haxe-callstack

		If defined, Reflaxe/C++ will generate content to track
		the Haxe callstack in C++ code. This define is required
		to use the `haxe.CallStack` class.
	**/
	var Callstack = "haxe-callstack";

	/**
		-D dont-cast-numeric-comparisons

		If defined, number comparisons will not be casted to 
		the same type.
	**/
	var DontCastNumComp = "dont-cast-numeric-comparisons";
}
