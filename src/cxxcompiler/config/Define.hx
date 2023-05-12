// =======================================================
// * Define
//
// List all the custom defines used in this project and
// provides access using a String enum abstract.
// =======================================================

package cxxcompiler.config;

enum abstract Define(String) from String to String {
	/**
		-D cxx_callstack

		If defined, Reflaxe/C++ will generate content to track
		the Haxe callstack in C++ code. This define is required
		to use the `haxe.CallStack` class.
	**/
	var Callstack = "cxx_callstack";

	/**
		-D dont-cast-numeric-comparisons

		If defined, number comparisons will not be casted to 
		the same type.
	**/
	var DontCastNumComp = "dont-cast-numeric-comparisons";

	/**
		-D keep-unused-locals

		If defined, unused local variables are generated.
	**/
	var KeepUnusedLocals = "keep-unused-locals";

	/**
		-D keep-useless-exprs

		If defined, expressions that don't do anything
		are still generated.
	**/
	var KeepUselessExprs = "keep-useless-exprs";
}
