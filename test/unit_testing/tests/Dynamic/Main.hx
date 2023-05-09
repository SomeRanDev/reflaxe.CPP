package;

class Test {
	public var a: Int = 0;
	public function new() {}
	public function test() { trace("Hello!"); }
	public function toString() { return "this is toString"; }
}

function main() {
	final d: Dynamic = new Test();
	d.test();

	trace(d);

	trace(d.a);
	d.a = 123;
	trace(d.a);
}
