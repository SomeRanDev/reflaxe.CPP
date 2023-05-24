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

var returnCode = 0;
function assert(b: Bool, infos: Null<haxe.PosInfos> = null) {
	if(!b) {
		haxe.Log.trace("Assert failed", infos);
		returnCode = 1;
	}
}

function main() {
	final d: Dynamic = new Test();
	d.test();

	// Test toString
	assert(Std.string(d) == "this is toString");

	// Test Dynamic props
	assert(d.a == 0);
	d.a = 123;
	assert(d.a == 123);

	// Test Dynamic functions
	final d2: Dynamic = new HasParam<Int>(333);
	assert(Std.string(d2) == "Dynamic");
	assert(d2.getT() == 333);

	// Test property not found
	try {
		d2.bla();
	} catch(e) {
		// You won't get callstack without uncommenting 
		// `-D cxx_callstack` from Test.hxml
		assert(e.message == "Property does not exist");
	}

	// Test extern types (Array is extern)
	final arr: Dynamic = [1, 2, 3];
	arr.push("Test");
	arr.push([1, 2]);
	assert(arr.length == 5);
	assert(Std.string(arr) == "[1, 2, 3, Test, [1, 2]]");
	assert(arr[2] == 3);
	assert((arr[4][1] = 333) == 333);
	assert(arr[4][0] == 1);
	assert(arr[4] == [1, 333]);
	assert(Std.string(arr[4]) == "[1, 333]");

	// Test String
	var str: Dynamic = "Hello!";
	assert(str == "Hello!");
	assert((str + " Goodbye!") == "Hello! Goodbye!");
	str += " Goodbye!";
	assert(str == "Hello! Goodbye!");

	// Test numbers
	var num: Dynamic = 10;
	assert(num + 10 == 20);
	assert(num - 10 == 0);
	assert(num * 5 == 50);
	assert(num / 5 == 2);

	num += 0;
	assert(num == 10);

	num -= 2;
	assert(num == 8);

	num *= 2;
	assert(num == 16);

	num /= 2;
	assert(num == 8);
}
