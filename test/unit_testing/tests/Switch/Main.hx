package;

var returnCode = 0;
function assert(b: Bool) {
	if(!b) {
		returnCode = 1;
	}
}

// Statement-position string switch with a default. The bucket for
// length 1 contains both "A" and "B"; any other length-1 input
// must hit the default.
function stmtSwitch(s: String): String {
	var matched = "?";
	switch(s) {
		case "A": matched = "A";
		case "B": matched = "B";
		default:  matched = "default";
	}
	return matched;
}

// Value-position string switch — every path must yield an `Int`,
// otherwise the codegen trips `-Werror=return-type`.
function valueSwitch(s: String): Int {
	return switch(s) {
		case "A": 1;
		case "B": 2;
		case _:   99;
	}
}

enum Test {
	One;
	Two;
	Three;
	Four;
}

function main() {
	final a = 123;
	switch(a) {
		case 1: assert(false);
		case 2: assert(false);
		case 123: assert(true);
	}

	switch(a) {
		case 1: assert(false);
		case 2: assert(false);
		case 3: assert(false);
		default: assert(true);
	}

	// ---

	final str = "Hello";
	switch(str) {
		case "Hello": assert(true);
		case "Goodbye": assert(false);
		case "Blablabla": assert(false);
	}

	// String switch with same-length cases + default: exercises the
	// `compileSwitchOptimizedForStrings` length-bucketed path. Inputs
	// matching a bucket's length but no case inside it must fall
	// through to `default`. Wrapped in helper functions so each
	// emits its own `__temp` (the codegen declares the temp at
	// function scope; calling one switch then another from `main`
	// would collide).
	assert(stmtSwitch("C") == "default");
	assert(stmtSwitch("A") == "A");
	assert(valueSwitch("C") == 99);
	assert(valueSwitch("B") == 2);

	// ---

	final result = switch(a) {
		case 111: 222;
		case 222: 444;
		case _: 0;
	}

	assert(result == 0);

	// ---

	final myEnum = Two;
	final result = switch(myEnum) {
		case One: 1;
		case Two: 0;
		case Three: 3;
		case Four: 4;
		case _: -1;
	}

	assert(result == 0);

	// ---

	if(returnCode != 0) {
		Sys.exit(returnCode);
	}
}
