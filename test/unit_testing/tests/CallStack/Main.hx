package;

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
	final result = "[FilePos(Method(Main_Fields_, test1), test/unit_testing/tests/CallStack/Main.hx, 8, 1), " + 
		"FilePos(Method(Main_Fields_, test2), test/unit_testing/tests/CallStack/Main.hx, 12, 1), " + 
		"FilePos(Method(Main_Fields_, test3), test/unit_testing/tests/CallStack/Main.hx, 16, 1)]";

	if(Std.string(callstack) != result) {
		Sys.println("Failed");
		Sys.exit(1);
	}

	// ---

	final callstackStr = haxe.CallStack.toString(callstack);
	// TODO: test this? (comparing it doesn't seem to work?)
}
