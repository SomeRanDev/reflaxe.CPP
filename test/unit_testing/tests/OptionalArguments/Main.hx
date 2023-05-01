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

	static function testBackOpt(first: Int, second: String = "test") {
		assert(first < 0);
		assert(StringTools.startsWith(second, "test"));
	}

	static function testFrontOpt(first: Int = 123, second: String) {
		assert(first > 100);
		assert(second == "test");
	}

	static function testQuestionOpt(?maybeInt: Int, ?maybeString: String) {
		if(maybeInt == null) assert(maybeInt == null);
		else assert(maybeInt == 111);

		if(maybeString == null) assert(maybeString == null);
		else assert(maybeString == "111");
	}

	static function testMixedOpt(first: Int = 100, second: String, third: Bool = true, fourth: Int) {
		assert(first >= 100);
		assert(StringTools.startsWith(second, "test"));
		assert(third);
		assert(fourth < 0);
	}

	public static function main() {
		// test optional argument
		testBackOpt(-1);
		testBackOpt(-100, "testthing");

		// front optional argument
		testFrontOpt(101, "test");
		testFrontOpt("test");

		// test ?arg
		testQuestionOpt(111);
		testQuestionOpt("111");
		testQuestionOpt();
		testQuestionOpt(null, "111");
		testQuestionOpt(111, null);

		// test mixed
		testMixedOpt("test", -1);
		testMixedOpt(101, "test", -1);
		testMixedOpt("test", true, -1);
		testMixedOpt(102, "test", true, -1);

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
