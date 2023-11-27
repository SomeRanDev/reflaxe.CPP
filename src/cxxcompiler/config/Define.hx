// =======================================================
// * Define
//
// List all the custom defines used in this project and
// provides access using a String enum abstract.
// =======================================================

package cxxcompiler.config;

enum abstract Define(String) from String to String {
	/**
		-D cxx_measure

		If defined, the time it takes to compile various
		parts of the Haxe AST will be printed.

		One may also use `-D reflaxe_measure` to get
		the full compilation time.
	**/
	var Measure = "cxx_measure";

	/**
		-D cxx_callstack

		If defined, Reflaxe/C++ will generate content to track
		the Haxe callstack in C++ code. This define is required
		to use the `haxe.CallStack` class.
	**/
	var Callstack = "cxx_callstack";

	/**
		-D cxx_imprecise_number_types

		If defined, the `cxx.num` will use relative approximation
		number types that do not require an #include.
	**/
	var ImpreciseNumberTypes = "cxx_imprecise_number_types";

	/**
		-D cxx_exceptions_disabled

		If defined, Reflaxe/C++ will avoid generating exceptions.
		This includes `try`/`catch` statements and `throw` statements.
	**/
	var ExceptionsDisabled = "cxx_exceptions_disabled";

	/**
		-D cxx_inline_trace_disabled

		If defined, `trace` with constant arguments will not be optimized
		into direct `std::cout` statements.
	**/
	var InlineTraceDisabled = "cxx_inline_trace_disabled";

	/**
		-D cxx_disable_ptr_to_string

		If defined, removes the `cxx.Ptr` `toString`
		method. This prevents auto conversion of `cxx.Ptr`
		to `String` if such behavior is undesired.
	**/
	var DisablePtrToString = "cxx_disable_ptr_to_string";

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

	/**
		-D cxx-no-null-warnings

		If defined, Reflaxe/C++ will not print warnings
		about non-nullable types being assigned `null`.
	**/
	var NoNullAssignWarnings = "cxx-no-null-warnings";

	/**
		-D cmake

		If defined, a `CMakeLists.txt` file will be
		generated in the output folder.
	**/
	var CMake = "cmake";
}
