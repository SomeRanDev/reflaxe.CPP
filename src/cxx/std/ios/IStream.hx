package cxx.std.ios;

/**
	Incomplete. Feel free to contribute needed fields:
	https://cplusplus.com/reference/istream/istream/
**/
@:cxxStd
@:cppStd
@:native("std::istream")
@:include("istream", true)
extern class IStream {
	public overload function get(): Int;
	public overload function get(c: cxx.Ref<cxx.Char>): cxx.Ref<OStream>;
	public function peek(): Int;
}
