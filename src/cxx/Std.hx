package cxx;

@:cxxStd
extern class Std {
	@:native("std::cin")
	@:include("iostream", true)
	public static var cin: cxx.Value<cxx.std.ios.IStream>;

	@:native("std::cout")
	@:include("iostream", true)
	public static var cout: cxx.Value<cxx.std.ios.OStream>;

	@:native("std::cerr")
	@:include("iostream", true)
	public static var cerr: cxx.Value<cxx.std.ios.OStream>;

	@:native("std::clog")
	@:include("iostream", true)
	public static var clog: cxx.Value<cxx.std.ios.OStream>;

	// TODO:
	// public static var wcin: cxx.std.WIStream;
	// public static var wcout: cxx.std.WOStream;
	// public static var wcerr: cxx.std.WOStream;
	// public static var wclog: cxx.std.WOStream;
}
