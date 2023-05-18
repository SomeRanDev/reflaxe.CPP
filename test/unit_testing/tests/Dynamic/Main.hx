package;

class Test {
	public var a: Int = 0;
	public function new() {}
	public function test() { trace("Hello!"); }
	public function toString() { return "this is toString"; }
}

class HasParam<T> {
	public var t: T;
	public function new(t: T) { this.t = t; }
	public function test() { trace("Hello!"); }
	public function getT(): T return t;
}

function main() {
	final d: Dynamic = new Test();
	d.test();

	trace(d);

	trace(d.a);
	d.a = 123;
	trace(d.a);

	final d2: Dynamic = new HasParam<Int>(333);
	trace(d2);
	trace(d2.getT());

	try {
		d2.bla();
	} catch(e) {
		Sys.println(e.details());
	}
}
