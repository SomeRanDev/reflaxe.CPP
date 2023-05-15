package cxx;

@:cxxStd
extern class Std {
	@:native("std::cin")
	public static var cin: cxx.Value<cxx.std.ios.IStream>;

	@:native("std::cout")
	public static var cout: cxx.Value<cxx.std.ios.OStream>;

	@:native("std::cerr")
	public static var cerr: cxx.Value<cxx.std.ios.OStream>;

	@:native("std::clog")
	public static var clog: cxx.Value<cxx.std.ios.OStream>;

	// TODO:
	// public static var wcout: cxx.std.WOStream;
	// public static var wcerr: cxx.std.WOStream;
	// public static var wclog: cxx.std.WOStream;
}
