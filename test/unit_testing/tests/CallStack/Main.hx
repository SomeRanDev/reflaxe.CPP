package;

function assert(b: Bool) {
	if(!b) {
		Sys.println("Failed");
		Sys.exit(1);
	}
}

function main() {
	test1();
}

function test1() {
	test2();
}

function test2() {
	test3();
}

function test3() {
	final callstack = haxe.CallStack.callStack();

	// expected output
	Sys.println(callstack);
	Sys.println("");
	Sys.println(haxe.CallStack.toString(callstack));

	switch(callstack[3]) {
		case FilePos(Method("Main_Fields_", "main"), _, 11, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[2]) {
		case FilePos(Method("Main_Fields_", "test1"), _, 15, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[1]) {
		case FilePos(Method("Main_Fields_", "test2"), _, 19, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[0]) {
		case FilePos(Method("Main_Fields_", "test3"), _, 23, 1): assert(true);
		case _: assert(false);
	}
}
