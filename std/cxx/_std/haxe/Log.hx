package haxe;

@:cxxStd
@:haxeStd
@:pseudoCoreApi
@:headerInclude("iostream", true)
class Log {
	public static function formatOutput(v: String, infos: Null<PosInfos> = null): String {
		if (infos == null) {
			return v;
		}

		var pstr = infos.fileName + ":" + infos.lineNumber;

		var extra = "";
		if(infos.customParams != null) {
			for(v in infos.customParams) {
				extra += (", " + v);
			}
		}

		return pstr + ": " + v + extra;
	}

	public static dynamic function trace(v: cxx.DynamicToString, infos: Null<PosInfos> = null): Void {
		var str = formatOutput(v, infos);
		Sys.println(str);
	}
}
