package;

var returnCode = 0;

function assert(b: Bool, infos: Null<haxe.PosInfos> = null) {
	if(!b) {
		haxe.Log.trace("Assert failed", infos);
		returnCode = 1;
	}
}

function main() {
	test1();
	checkLocalFuncs();

	if(returnCode != 0) {
		Sys.exit(returnCode);
	}
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
	Sys.println(haxe.CallStack.toString(callstack));

	switch(callstack[0]) {
		case FilePos(Method("_Main.Main_Fields_", "test3"), _, 30, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[1]) {
		case FilePos(Method("_Main.Main_Fields_", "test2"), _, 26, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[2]) {
		case FilePos(Method("_Main.Main_Fields_", "test1"), _, 22, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[3]) {
		case FilePos(Method("_Main.Main_Fields_", "main"), _, 13, 1): assert(true);
		case _: assert(false);
	}
}

// ---

function checkLocalFuncs() {
	function a() {
		final b = () -> test4();
		b();
	}
	a();
}

function test4() {
	final callstack = haxe.CallStack.callStack();

	// expected output
	Sys.println(haxe.CallStack.toString(callstack));

	switch(callstack[0]) {
		case FilePos(Method("_Main.Main_Fields_", "test4"), _, 67, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[1]) {
		case FilePos(Method("_Main.Main_Fields_", "checkLocalFuncs.a.b"), _, 60, 3): assert(true);
		case _: assert(false);
	}

	switch(callstack[2]) {
		case FilePos(Method("_Main.Main_Fields_", "checkLocalFuncs.a"), _, 61, 2): assert(true);
		case _: assert(false);
	}

	switch(callstack[3]) {
		case FilePos(Method("_Main.Main_Fields_", "checkLocalFuncs"), _, 63, 1): assert(true);
		case _: assert(false);
	}

	switch(callstack[4]) {
		case FilePos(Method("_Main.Main_Fields_", "main"), _, 14, 1): assert(true);
		case _: assert(false);
	}
}
