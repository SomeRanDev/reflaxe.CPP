package;

/**
	A class containing the implementation for `Sys.environment`.
**/
@:cxxStd
final class Sys_Environment {
	public static function environment(): Map<String, String> {
		var strings: Array<String> = [];

		// https://stackoverflow.com/a/71483564/8139481
		untyped __cpp__("char** env;
#if defined(WIN) && (_MSC_VER >= 1900)
	env = *__p__environ();
#else
	extern char** environ;
	env = environ;
#endif
	for (; *env; ++env) {
		{0}(*env);
	}", strings.push_back);

		final result: Map<String, String> = [];
		for(en in strings) {
			final index = en.indexOf("=");
			if(index >= 0) {
				result.set(en.substr(0, index), en.substr(index + 1));
			}
		}
		return result;
	}
}

/**
	A class containing the implementation for `Sys.systemName`.
**/
@:cxxStd
final class Sys_SystemName {
	public static function systemName(): String {
		untyped __cpp__("#if defined(_WIN32)
return \"Windows\";
#elif defined(BSD)
return \"BSD\";
#elif defined(__linux__)
return \"Linux\";
#elif defined(__APPLE__) && defined(__MACH__)
return \"Mac\";
#endif
");
		return "";
	}
}

/**
	A class containing the implementation for `Sys.args`.

	Stores the args at the start of the program for later access.
**/
@:cxxStd
final class Sys_Args {
	/**
		Store program arguments.
	**/
	static var _args: cxx.Value<Array<String>> = [];

	/**
		Automatically called at start of the main function if this class is generated.

		Converts the program's arguments to an `Array<String>` for later use.
	**/
	@:prependToMain
	public static function setupArgs(argCount: Int, args: cxx.CArray<cxx.ConstCharPtr>) {
		for(i in 0...argCount) {
			_args.push(args[i].toString());
		}
	}

	public static function args(): Array<String> {
		return _args;
	}
}

/**
	A class containing the implementation for `Sys.getEnv`.
**/
@:cxxStd
final class Sys_GetEnv {
	/**
		Unfortunately, the windows implementation of this function is massive.
	**/
	public static function getEnv(s: String): Null<String> {
		#if windows
		// Based on:
		// https://learn.microsoft.com/en-us/cpp/c-runtime-library/reference/getenv-s-wgetenv-s?view=msvc-170#example

		// Make variables
		var libvar: cxx.Ptr<cxx.Char> = cast 0;
		var requiredSize: cxx.num.SizeT = 0;

		// Check if exists
		cxx.Stdlib.getEnv(requiredSize, untyped __cpp__("nullptr"), 0, @:privateAccess s.c_str());
		if(requiredSize == 0) return null;

		// If it does, `requiredSize` contains the allocation size.
		// Allocate a `char*` of size `requiredSize`.
		libvar = cxx.Stdlib.ccast(cxx.Stdlib.malloc(requiredSize * cxx.Stdlib.sizeof(untyped __cpp__("char"))));

		// Get the variable
		cxx.Stdlib.getEnv(requiredSize, libvar, requiredSize, @:privateAccess s.c_str());

		// Convert the `char*` to `std::string`, free it, then return the string.
		final str: String = libvar.toString();
		cxx.Stdlib.free(libvar);
		return str;
		#else
		final result = cxx.Stdlib.getEnv(@:privateAccess s.c_str());
		return result.isNull() ? null : result.toString();
		#end
	}
}

/**
	A class containing the implementation for `Sys.cpuTime`.

	Records the time the program starts to calculate the program time later.
**/
@:cxxStd
final class Sys_CpuTime {
	/**
		Store when the program started.
	**/
	static var _startTime: cxx.std.chrono.TimePoint<cxx.std.chrono.SystemClock>;

	/**
		Automatically called at start of the main function if this class is generated.

		Records the current time toe `_startTime`.
	**/
	@:prependToMain
	public static function setupStart() {
		_startTime = cxx.std.chrono.SystemClock.now();
	}

	public static function cpuTime(): Float {
		return Sys.time() - (_startTime.timeSinceEpoch().toMilliseconds().count() / 1000.0);
	}
}

@:cxxStd
@:require(sys)
extern class Sys {
	public static extern inline function print(v: cxx.DynamicToString): Void {
		untyped __include__("iostream", true);
		untyped __cpp__("std::cout << {0}", Std.string(v));
	}

	public static extern inline function println(v: cxx.DynamicToString): Void {
		untyped __include__("iostream", true);
		untyped __cpp__("std::cout << {0} << std::endl", Std.string(v));
	}

	public static extern inline function args(): Array<String> {
		return Sys_Args.args();
	}

	public static extern inline function getEnv(s: String): Null<String> {
		return Sys_GetEnv.getEnv(s);
	}

	public static extern inline function putEnv(s: String, v: Null<String>): Void {
		#if windows
		cxx.Stdlib.putEnv(@:privateAccess s.c_str(), @:privateAccess (v ?? "").c_str());
		#elseif (mac || linux)
		if(v == null || v.length == 0) {
			cxx.Stdlib.unsetEnv(@:privateAccess s.c_str());
		} else {
			cxx.Stdlib.setEnv(@:privateAccess s.c_str(), @:privateAccess v.c_str(), 1);
		}
		#else
		throw "A platform define must be made to use Sys.putEnv. Add -D windows, -D linux, or -D mac to your Haxe project.";
		#end
	}

	public static extern inline function environment(): Map<String, String> {
		return Sys_Environment.environment();
	}

	public static extern inline function sleep(seconds: Float): Void {
		cxx.Stdlib.sleep(cxx.std.chrono.Literals.toMilliseconds(Std.int(seconds * 1000.0)));
	}

	public static extern inline function setTimeLocale(loc: String): Bool {
		return !cxx.Stdlib.setLocale(untyped __cpp__("LC_TIME"), @:privateAccess loc.c_str()).isNull();
	}

	public static extern inline function getCwd(): String {
		return cxx.std.FileSystem.currentPath().string();
	}

	public static extern inline function setCwd(s: String): Void {
		cxx.std.FileSystem.currentPath(s);
	}

	public static extern inline function systemName(): String {
		return Sys_SystemName.systemName();
	}

	static function command(cmd: String, ?args: Array<String>): Int;

	@:native("exit")
	@:include("cstdlib", true)
	public static function exit(code: Int): Void;

	public static extern inline function time(): Float {
		return cxx.std.chrono.SystemClock.now().timeSinceEpoch().toMilliseconds().count() / 1000.0;
	}

	public static extern inline function cpuTime(): Float {
		return Sys_CpuTime.cpuTime();
	}

	@:deprecated("Use programPath instead")
	public static extern inline function executablePath(): String {
		return programPath();
	}

	static function programPath(): String;
	static function getChar(echo: Bool): Int;

	public static extern inline function stdin(): haxe.io.Input {
		return new cxx.io.NativeInput(cxx.Std.cin);
	}

	public static extern inline function stdout(): haxe.io.Output {
		return new cxx.io.NativeOutput(cxx.Std.cout);
	}

	public static extern inline function stderr(): haxe.io.Output {
		return new cxx.io.NativeOutput(cxx.Std.cerr);
	}
}