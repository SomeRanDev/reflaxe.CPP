package cxx.std.ios;

/**
	Incomplete. Feel free to contribute needed fields:
	https://cplusplus.com/reference/sstream/stringstream/
**/
@:cxxStd
@:include("sstream", true)
@:native("std::stringstream")
extern class StringStream extends IOStream {
	public function new();
	public function str(): String;

	@:nativeName("operator<<")
	public function add(any: Dynamic): StringStream;
}
