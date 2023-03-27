package;

class SysImpl {
	public static function environment(): Map<String, String> {
		return [];
	}

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

@:require(sys)
extern class Sys {
	public static extern inline function print(v: ucpp.DynamicToString): Void {
		untyped __ucpp__("std::cout << {}", v);
	}

	public static extern inline function println(v: ucpp.DynamicToString): Void {
		untyped __ucpp__("std::cout << {} << std::endl", v);
	}

	static function args(): Array<String>;

	public static extern inline function getEnv(s: String): Null<String> {
		final result = ucpp.Stdlib.getEnv(@:privateAccess s.c_str());
		return result.isNull() ? null : result.toString();
	}

	public static extern inline function putEnv(s: String, v: String): Void {
		final inputAssign = (s + "=" + v);
		ucpp.Stdlib.putEnv(@:privateAccess inputAssign.data());
	}

	// public static extern inline function environment(): Map<String, String> {
	// 	return SysImpl.environment();
	// }

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
	public static function exit(code: Int): Void;

	static function time(): Float;
	static function cpuTime(): Float;
	@:deprecated("Use programPath instead") static function executablePath(): String;
	static function programPath(): String;
	static function getChar(echo: Bool): Int;
	static function stdin(): haxe.io.Input;
	static function stdout(): haxe.io.Output;
	static function stderr(): haxe.io.Output;
}