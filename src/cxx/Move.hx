package cxx;

/**
	Compiles a type as an xvalue in C++ (Type&&).
**/
@:cxxStd
@:extern
@:noInclude
@:nativeTypeCode("{type0}&&")
typedef Move<T> = T;

/**
	Generates a `std::move` expression in C++.
**/
@:nativeFunctionCode("std::move({arg0})")
extern function move<T>(value: Value<T>): Move<T>;
