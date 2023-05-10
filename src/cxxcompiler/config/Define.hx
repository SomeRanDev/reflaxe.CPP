package cxxcompiler.config;

enum abstract Define(String) from String to String {
	/**
		-D native-throw

		If defined, Reflaxe/C++ will generate "throw" statements
		in C++ from "throw" statements in Haxe.
	**/
	var NativeThrow = "native-throw";
}
