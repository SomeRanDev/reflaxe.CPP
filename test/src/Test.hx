package;

abstract Test(Int) from Int to Int {
	public function new(i: Int) {
		this = i;
	}

	public function toDouble(): Int {
		return this * 2;
	}
}

function main() {
	trace("Hello world!");

	var a: Ptr<Int> = cast Stdlib.malloc(12);
	Stdlib.free(cast a);

	final b = new Test(123);
	trace(Std.string(b.toDouble()));
}
