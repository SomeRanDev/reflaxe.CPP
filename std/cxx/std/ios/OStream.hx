package cxx.std.ios;

/**
	Incomplete. Feel free to contribute needed fields:
	https://cplusplus.com/reference/ostream/ostream/
**/
@:cxxStd
@:cppStd
@:native("std::ostream")
@:include("ostream", true)
extern class OStream {
	public function put(c: cxx.Char): OStream;
	public function flush(): cxx.Ref<OStream>;
}
