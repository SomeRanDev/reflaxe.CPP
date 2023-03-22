package;

import ucpp.std.Pair;
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
		final bla = [1 => 123];
		trace(bla[1]);

		final a = new ucpp.std.Map<Int, Int>();

		a.insert(new Pair(12, 24));

		trace(a.at(12));

		var it = a.begin();

		trace(it.first);

		it.increment();

		trace(it == a.end());

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}