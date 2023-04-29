package cxx;

@:cxxStd
extern class Stdlib {
	@:native("malloc")
	@:include("stdlib.h", true)
	public static extern function malloc(size: Int): Ptr<Void>;

	@:native("free")
	@:include("stdlib.h", true)
	public static extern function free(p: Ptr<Void>): Void;

	@:native("sizeof")
	public static extern function sizeof(a: Dynamic): Int;

	@:native("std::to_string")
	@:include("string", true)
	public static extern function intToString(i: Int): String;

	@:native("std::getenv")
	@:include("cstdlib", true)
	public static extern function getEnv(c: cxx.ConstCharPtr): cxx.Ptr<cxx.Char>;

	#if windows

	@:native("putenv")
	@:include("cstdlib", true)
	public static extern function putEnv(input: cxx.Ptr<cxx.Char>): Int;

	#elseif (linux || mac)

	@:native("setenv")
	@:include("stdlib.h", true)
	public static extern function setEnv(envName: cxx.ConstCharPtr, envVal: cxx.ConstCharPtr, overwrite: Int): Int;

	@:native("unsetenv")
	@:include("stdlib.h", true)
	public static extern function unsetEnv(envName: cxx.ConstCharPtr): Int;

	#end

	@:native("std::this_thread::sleep_for")
	@:include("thread", true)
	public static extern function sleep(duration: cxx.std.chrono.Duration): Void;

	@:native("std::setlocale")
	@:include("clocale", true)
	public static extern function setLocale(category: Int, locale: cxx.ConstCharPtr): cxx.Ptr<cxx.Char>;
}
