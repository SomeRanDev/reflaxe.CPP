package haxe;

class Log {
	public static function formatOutput(str: String, infos: PosInfos): String {
		if (infos == null)
			return str;
		var pstr = infos.fileName + ":" + infos.lineNumber;
		return pstr + ": " + str;
	}

	@:include("iostream", true)
	public static dynamic function trace(v: String, ?infos: PosInfos): Void {
		var str = formatOutput(v, infos);
		untyped __cpp__("std::cout << {} << std::endl", str);
	}
}
