package;

import haxe.PosInfos;

class BaseClass {
	public function new() {}
}

class ChildClass extends BaseClass {
}

class AnotherClass {
	public function new() {}

	public function toString() { return "another class as string"; }
}

class ClassWInt {
	public function new() {}

	var number: Int = 123;
}

class Main {
	static var returnCode = 0;

	static function assert(b: Bool, infos: Null<PosInfos> = null) {
		if(!b) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	static function assertFloat(a: Float, b: Float, infos: Null<PosInfos> = null) {
		if(Math.abs(a - b) >= 0.001) {
			haxe.Log.trace("Assert failed", infos);
			returnCode = 1;
		}
	}

	public static function main() {
		// Std.isOfType
		final base = new BaseClass();
		final child = new ChildClass();
		final another = new AnotherClass();

		assert(Std.isOfType(child, ChildClass));
		assert(Std.isOfType(child, BaseClass));
		assert(!Std.isOfType(child, AnotherClass));

		assert(!Std.isOfType(another, ChildClass));
		assert(!Std.isOfType(another, BaseClass));
		assert(Std.isOfType(another, AnotherClass));

		// Std.string
		var a: Null<Int> = null;
		assert(Std.string(a) == "null");

		a = 123;
		assert(Std.string(a) == "123");

		assert(Std.string(Main) == "Class<Main>");
		assert(Std.string(Std) == "Class<Std>");

		assert(Std.string(another) == "another class as string");
		assert(Std.string(another) == another.toString());

		final anotherVal: ucpp.Value<AnotherClass> = new AnotherClass();
		assert(Std.string(anotherVal) == anotherVal.toString());

		assert(Std.string(base) == "<unknown(size:" + ucpp.Stdlib.sizeof(base) + ")>");

		final baseVal: ucpp.Value<BaseClass> = new BaseClass();
		assert(Std.string(baseVal) == "<unknown(size:" + ucpp.Stdlib.sizeof(baseVal) + ")>");

		final numVal: ucpp.Value<ClassWInt> = new ClassWInt();
		assert(Std.string(numVal) == "<unknown(size:" + ucpp.Stdlib.sizeof(numVal) + ")>");

		// Std.int
		assert(Std.int(4.5) == 4);
		assert(Std.int(0.999999) == 0);
		assert(Std.int(0) == 0);
		assert(Std.int(1.5) == 1);

		// Std.parseInt
		assert(Std.parseInt("0") == 0);
		assert(Std.parseInt("123") == 123);
		assert(Std.parseInt("number!") == null);
		assert(Std.parseInt("1") != null);

		// Std.parseFloat
		assertFloat(Std.parseFloat("1.1"), 1.1);
		assertFloat(Std.parseFloat("2.0"), 2.0);
		assertFloat(Std.parseFloat("0.5"), 0.5);
		assertFloat(Std.parseFloat("0.0001"), 0.0001);
		assert(Math.isNaN(Std.parseFloat("another number!")));
		assert(!Math.isNaN(Std.parseFloat("0")));

		// Std.random
		// (lmao how do you even test this?)
		for(i in 0...1000) {
			final v = Std.random(10);
			assert(v >= 0 && v < 10);
		}

		if(returnCode != 0) {
			Sys.exit(returnCode);
		}
	}
}