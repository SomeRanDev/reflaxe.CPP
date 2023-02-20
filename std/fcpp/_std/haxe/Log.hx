package haxe;

@:pseudoCoreApi
@:headerInclude("iostream", true)
class Log {
	public static function formatOutput(v: String, infos: Null<PosInfos> = null): String {
		if (infos == null)
			return v;
		var pstr = infos.fileName + ":" + infos.lineNumber;
		return pstr + ": " + v;
	}

	public static dynamic function trace(v: String, infos: Null<PosInfos> = null): Void {
		var str = formatOutput(v, infos);
		untyped __cpp__("std::cout << {} << std::endl", str);
	}
}
