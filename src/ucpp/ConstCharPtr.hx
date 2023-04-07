package ucpp;

@:native("const char*")
@:valueType
extern class ConstCharPtr {
	@:nativeFunctionCode("std::string({this})")
	@:include("string", true)
	public function toString(): String;
}
