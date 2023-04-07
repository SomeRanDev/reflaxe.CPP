package ucpp;

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
	public static extern function getEnv(c: ucpp.ConstCharPtr): ucpp.Ptr<ucpp.Char>;

	#if windows

	@:native("putenv")
	@:include("cstdlib", true)
	public static extern function putEnv(input: ucpp.Ptr<ucpp.Char>): Int;

	#elseif (linux || mac)

	@:native("setenv")
	@:include("stdlib.h", true)
	public static extern function setEnv(envName: ucpp.ConstCharPtr, envVal: ucpp.ConstCharPtr, overwrite: Int): Int;

	@:native("unsetenv")
	@:include("stdlib.h", true)
	public static extern function unsetEnv(envName: ucpp.ConstCharPtr): Int;

	#end

	@:native("std::this_thread::sleep_for")
	@:include("thread", true)
	public static extern function sleep(duration: Float): Void;

	@:native("std::setlocale")
	@:include("clocale", true)
	public static extern function setLocale(category: Int, locale: ucpp.ConstCharPtr): ucpp.Ptr<ucpp.Char>;
}
