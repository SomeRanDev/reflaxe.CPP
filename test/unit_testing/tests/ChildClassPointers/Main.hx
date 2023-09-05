package;

var returnCode = 0;
function assert(v: Bool) {
	if(!v) {
		returnCode = 1;
	}
}

class A {
	public var val: Int;
}

class B extends A {
	public function new() {
		val = 0;
	}
}

class C {
	public var val: Int;
	public function new() {
		val = 100;
	}
}

function main() {
	var a: cxx.Ptr<A> = cxx.Ptr.Null;
	var b: cxx.Ptr<B> = new B();
	
	// Valid, B is child of A
	a = b;

	var c: cxx.Ptr<C> = new C();

	// Invalid, C is not child A (uncomment to test)
	// a = c;

	if(returnCode != 0) {
		Sys.exit(returnCode);
	}
}
