package ucpp;

@:ucppStd
@:native("char")
extern class Char {
	@:include("string", true)
	@:nativeFunctionCode("std::string({this})")
	public function toString(): String;
}
