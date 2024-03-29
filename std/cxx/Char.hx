package cxx;

@:cxxStd
@:numberType(8, false, true)
@:native("char")
extern class Char {
	@:include("string", true)
	@:nativeFunctionCode("std::string({this})")
	public function toString(): String;
}
