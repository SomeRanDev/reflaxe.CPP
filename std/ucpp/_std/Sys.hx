package;

class SysImpl {
	// Store program arguments
	static var _args: ucpp.Value<Array<String>> = [];

	// Automatically called at start of the main
	// function if this class is generated.
	@:prependToMain
	public static function setupArgs(argCount: Int, args: ucpp.CArray<ucpp.ConstCharPtr>) {
		for(i in 0...argCount) {
			_args.push(args[i].toString());
		}
	}

	public static function args(): Array<String> {
		return _args;
	}

	// ---

	public static function environment(): Map<String, String> {
		var strings: Array<String> = [];

		// https://stackoverflow.com/a/71483564/8139481
		untyped __ucpp__("char** env;
#if defined(WIN) && (_MSC_VER >= 1900)
	env = *__p__environ();
#else
	extern char** environ;
	env = environ;
#endif
	for (; *env; ++env) {
		{}(*env);
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

	// ---

	public static function systemName(): String {
		untyped __ucpp__("#if defined(_WIN32)
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
	A class containing the implementation for `Sys.cpuTime`.

	Records the time the program starts to calculate the program time later.
**/
final class Sys_CpuTime {
	/**
		Store when the program started.
	**/
	static var _startTime: ucpp.std.chrono.TimePoint<ucpp.std.chrono.SystemClock>;

	/**
		Automatically called at start of the main function if this class is generated.

		Records the current time toe `_startTime`.
	**/
	@:prependToMain
	public static function setupStart() {
		_startTime = ucpp.std.chrono.SystemClock.now();
	}

	public static function cpuTime(): Float {
		return Sys.time() - (_startTime.timeSinceEpoch().toMilliseconds().count() / 1000.0);
	}
}

@:require(sys)
extern class Sys {
	public static extern inline function print(v: Dynamic): Void {
		untyped __ucpp__("std::cout << {}", Std.string(v));
	}

	public static extern inline function println(v: Dynamic): Void {
		untyped __ucpp__("std::cout << {} << std::endl", Std.string(v));
	}

	public static extern inline function args(): Array<String> {
		return SysImpl.args();
	}

	public static extern inline function getEnv(s: String): Null<String> {
		final result = ucpp.Stdlib.getEnv(@:privateAccess s.c_str());
		return result.isNull() ? null : result.toString();
	}

	public static extern inline function putEnv(s: String, v: Null<String>): Void {
		#if windows
		final inputAssign = (s + "=" + (v ?? ""));
		ucpp.Stdlib.putEnv(@:privateAccess inputAssign.data());
		#elseif (mac || linux)
		if(v == null || v.length == 0) {
			ucpp.Stdlib.unsetEnv(@:privateAccess s.c_str());
		} else {
			ucpp.Stdlib.setEnv(@:privateAccess s.c_str(), @:privateAccess v.c_str(), 1);
		}
		#else
		throw "A platform define must be made to use Sys.putEnv. Add -D windows, -D linux, or -D mac to your Haxe project.";
		#end
	}

	public static extern inline function environment(): Map<String, String> {
		return SysImpl.environment();
	}

	public static extern inline function sleep(seconds: Float): Void {
		ucpp.Stdlib.sleep(seconds * 1000.0);
	}

	public static extern inline function setTimeLocale(loc: String): Bool {
		return !ucpp.Stdlib.setLocale(untyped __ucpp__("LC_TIME"), @:privateAccess loc.c_str()).isNull();
	}

	static function getCwd(): String;
	static function setCwd(s: String): Void;

	public static extern inline function systemName(): String {
		return SysImpl.systemName();
	}

	static function command(cmd: String, ?args: Array<String>): Int;

	@:native("exit")
	@:include("cstdlib", true)
	public static function exit(code: Int): Void;

	public static extern inline function time(): Float {
		return ucpp.std.chrono.SystemClock.now().timeSinceEpoch().toMilliseconds().count() / 1000.0;
	}

	public static extern inline function cpuTime(): Float {
		return Sys_CpuTime.cpuTime();
	}

	@:deprecated("Use programPath instead") static function executablePath(): String;
	static function programPath(): String;
	static function getChar(echo: Bool): Int;
	static function stdin(): haxe.io.Input;
	static function stdout(): haxe.io.Output;
	static function stderr(): haxe.io.Output;
}