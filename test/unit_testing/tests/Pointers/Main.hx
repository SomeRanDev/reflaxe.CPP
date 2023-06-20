package;

var exitCode = 0;
function assert(v: Bool) {
	if(!v) {
		exitCode = 1;
	}
}

function main() {
	var a: cxx.Ptr<Int> = cxx.Ptr.Null;
	assert(a.isNull()); // starts nullptr

	var b = 123;
	a = b;

	assert(!a.isNull()); // isn't nullptr
	
	// compare pointers
	var c: cxx.Ptr<Int> = a;
	assert(a == c);
	assert(a.addrEquals(c));
	assert(!a.addrNotEquals(c));

	// normally, value is compared
	b = 100;
	assert(a == b);
	assert(c == b);

	b = 200;
	assert(a == b);
	assert(c == b);

	// toValue
	assert(a.toValue() == 200);

	// cxx.Syntax.toPointer
	final d = cxx.Syntax.toPointer(b);
	assert(!d.isNull());

	trace(cxx.Syntax.deref(d));

	if(exitCode != 0) {
		Sys.exit(exitCode);
	}
}
