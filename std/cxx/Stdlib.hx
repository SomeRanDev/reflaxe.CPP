package cxx;

@:cxxStd
extern class Stdlib {
	@:nativeFunctionCode("(({type1})({arg0}))")
	public static extern function ccast<T, U>(input: T): U;

	@:native("malloc")
	@:include("stdlib.h", true)
	public static extern function malloc(size: Int): cxx.VoidPtr;

	@:native("free")
	@:include("stdlib.h", true)
	public static extern function free(p: cxx.VoidPtr): Void;

	@:native("sizeof")
	public static extern function sizeof(a: Dynamic): Int;

	@:native("std::to_string")
	@:include("string", true)
	public static extern function intToString(i: Int): String;

	#if reflaxe_cpp_windows

	@:native("getenv_s")
	@:include("stdlib.h", true)
	public static extern function getEnv(pReturnValue: cxx.Ptr<cxx.num.SizeT>, buffer: cxx.Ptr<cxx.Char>, numberOfElements: cxx.num.SizeT, varname: cxx.ConstCharPtr): Void;

	@:native("_putenv_s")
	@:include("stdlib.h", true)
	public static extern function putEnv(name: cxx.ConstCharPtr, input: cxx.ConstCharPtr): Int;

	#elseif (reflaxe_cpp_linux || reflaxe_cpp_mac)

	@:native("std::getenv")
	@:include("cstdlib", true)
	public static extern function getEnv(c: cxx.ConstCharPtr): cxx.Ptr<cxx.Char>;

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
