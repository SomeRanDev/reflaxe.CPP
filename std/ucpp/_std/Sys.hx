package;

@:require(sys)
extern class Sys {
	public static extern inline function print(v: ucpp.DynamicToString): Void {
		untyped __ucpp__("std::cout << {}", v);
	}

	public static extern inline function println(v: ucpp.DynamicToString): Void {
		untyped __ucpp__("std::cout << {} << std::endl", v);
	}

	static function args(): Array<String>;
	static function getEnv(s: String): String;
	static function putEnv(s: String, v: String): Void;
	static function environment(): Map<String, String>;
	static function sleep(seconds: Float): Void;
	static function setTimeLocale(loc: String): Bool;
	static function getCwd(): String;
	static function setCwd(s: String): Void;
	static function systemName(): String;
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