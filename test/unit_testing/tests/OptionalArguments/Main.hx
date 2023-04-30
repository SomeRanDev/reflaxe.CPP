package;

import haxe.PosInfos;

class Main {
	static var returnCode = 0;
	public static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	static function testFrontOpt(first: Int = 123, second: String) {
		assert(first > 100);
		assert(second == "test");
	}

	public static function main() {
		// front optional argument
		testFrontOpt(101, "test");
		testFrontOpt("test");

		final a: Base = new Child();
		a.doThing("other");
		a.doThing2("other");

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}

class Base {
	public function new() {}

	public function doThing(num: Int = 100, other: String) {
		Main.assert(other == "other");
		Main.assert(num == 100);
	}

	public function doThing2(num: Int = 100, other: String) {
		Main.assert(other == "other");
		Main.assert(num == 100);
	}
}

class Child extends Base {
	public override function doThing(num: Int = 100, other: String) {
		Main.assert(other == "other");
		Main.assert(num == 100);
	}

	// Test conflicting default value (num: Int = 200 instead of 100)
	public override function doThing2(num: Int = 200, other: String) {
		Main.assert(other == "other");
		Main.assert(num == 200);
	}
}
