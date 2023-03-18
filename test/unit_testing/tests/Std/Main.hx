package;

import haxe.PosInfos;

class Main {
	static var returnCode = 0;

	static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	public static function main() {
		var a: Null<Int> = null;
		trace(Std.string(a));

		a = 123;
		trace(Std.string(a));

		trace(Std.string(Std));

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}