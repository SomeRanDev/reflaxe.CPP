package haxe;

@:headerInclude("iostream", true)
class Log {
	public static function formatOutput(str: String, infos: Null<PosInfos> = null): String {
		if (infos == null)
			return str;
		var pstr = infos.fileName + ":" + infos.lineNumber;
		return pstr + ": " + str;
	}

	public static dynamic function trace(v: String, infos: Null<PosInfos> = null): Void {
		var str = formatOutput(v, infos);
		untyped __cpp__("std::cout << {} << std::endl", str);
	}
}
