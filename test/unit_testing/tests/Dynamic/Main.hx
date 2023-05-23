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
		//d2.bla();
	} catch(e) {
		// You won't get callstack without uncommenting 
		// `-D cxx_callstack` from Test.hxml
		Sys.println(e.details());
	}

	// Test extern types
	try {
		final arr: Dynamic = [1, 2, 3];
		arr.push("Test");
		arr.push([1, 2]);
		trace(arr.length);
		trace(arr);
		trace(arr[2]);
		trace(arr[4][1] = 333);
		trace(arr[4][0]);
		trace(arr[4]);

		trace(arr[4] == [1, 333]);
	} catch(e) {
		trace(e.message);
	}
}
