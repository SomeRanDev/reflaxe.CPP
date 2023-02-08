package;

abstract Test(Int) from Int to Int {
	public function new(i: Int) {
		this = i;
	}

	public function toDouble(): Int {
		return this * 2;
	}
}

enum Test2 {
	One;
	Two;
	Three(a: Int);
}

function main() {
	trace("Hello world!");

	var a: Ptr<Int> = cast Stdlib.malloc(12);
	Stdlib.free(cast a);

	var c: Ptr<Int> = 123;

	var d = Three(123);
	switch(d) {
		case Three(v): trace(Std.string(v));
		case _:
	}

	final b = new Test(123);
	trace(Std.string(b.toDouble()));
}
