package cxx;

@:cxxStd
@:native("const char*")
@:valueType
extern class ConstCharPtr {
	@:nativeFunctionCode("std::string({this})")
	@:include("string", true)
	public function toString(): String;

	public static extern inline function fromString(s: String): ConstCharPtr {
		return @:privateAccess s.c_str();
	}
}
