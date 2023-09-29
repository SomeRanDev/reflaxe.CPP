package;

var returnCode = 0;
function assert(b: Bool) {
	if(!b) {
		returnCode = 1;
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
