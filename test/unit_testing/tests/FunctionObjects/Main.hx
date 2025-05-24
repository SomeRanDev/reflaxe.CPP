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

	static var thing = 0;
	static function bla() {
		thing++;
	}

	public static function main() {
		final func: () -> Void = bla;
		func();
		assert(thing == 1);

		var func2: Null<() -> Void> = null;
		if(func2 == null) {
			func2 = bla;
		}
		func2();
		assert(thing == 2);

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}