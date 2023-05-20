package;

class Main {
	public var other: cxx.Value<Other>;

	public function new() {}
}

function main() {
	trace("Hello world!");

	final m = new Main();
	final o = new Other2(m);

	final e = EnumLoop1.None;
	final e2 = EnumLoop2.Thing(e);
	final e3 = EnumLoop1.Thing(e2);

	trace(e3);
}
