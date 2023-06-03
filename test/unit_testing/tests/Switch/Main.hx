package;

var returnCode = 0;
function assert(b: Bool) {
	if(!b) {
		returnCode = 1;
	}
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

	final str = "Hello";
	switch(str) {
		case "Hello": assert(true);
		case "Goodbye": assert(false);
		case "Blablabla": assert(false);
	}

	if(returnCode != 0) {
		Sys.exit(returnCode);
	}
}
