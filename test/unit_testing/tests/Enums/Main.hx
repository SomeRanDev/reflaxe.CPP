package;

import haxe.PosInfos;

enum MyEnum {
	Entry1;
	Entry2(i: Int);
	Entry3(s: String);
}

class Main {
	static var returnCode = 0;
	static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	@:topLevel
	public static function main(): Int {
		final a = Entry1;
		final b = Entry2(123);
		final c = Entry3("Test");

		switch(b) {
			case Entry1: assert(false);
			case Entry2(i): {
				assert(i == 123);
			}
			case Entry3(s): assert(false);
		}

		switch(c) {
			case Entry1: assert(false);
			case Entry2(i): assert(false);
			case Entry3(s): {
				assert(s == "Test");
			}
		}

		return returnCode;
	}
}
