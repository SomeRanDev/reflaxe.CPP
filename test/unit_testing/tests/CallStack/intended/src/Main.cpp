#include "Main.h"

#include <cstdlib>
#include <deque>
#include <iostream>
#include <memory>
#include <string>
#include "haxe_CallStack.h"
#include "haxe_NativeStackTrace.h"
#include "Std.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 3, 1, "Main_Fields_"s, "main"s);
	
	HCXX_LINE(4);
	_Main::Main_Fields_::test1();
}

void _Main::Main_Fields_::test1() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 7, 1, "Main_Fields_"s, "test1"s);
	
	HCXX_LINE(8);
	_Main::Main_Fields_::test2();
}

void _Main::Main_Fields_::test2() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 11, 1, "Main_Fields_"s, "test2"s);
	
	HCXX_LINE(12);
	_Main::Main_Fields_::test3();
}

void _Main::Main_Fields_::test3() {
	HCXX_STACK_METHOD("test/unit_testing/tests/CallStack/Main.hx"s, 15, 1, "Main_Fields_"s, "test3"s);
	
	HCXX_LINE(16);
	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> callstack = haxe::_CallStack::CallStack_Impl_::callStack();
	HCXX_LINE(17);
	std::string result = "[FilePos(Method(Main_Fields_, test1), test/unit_testing/tests/CallStack/Main.hx, 8, 1), "s + "FilePos(Method(Main_Fields_, test2), test/unit_testing/tests/CallStack/Main.hx, 12, 1), "s + "FilePos(Method(Main_Fields_, test3), test/unit_testing/tests/CallStack/Main.hx, 16, 1)]"s;
	
	HCXX_LINE(21);
	if(Std::string(callstack) != result) {
		HCXX_LINE(22);
		HCXX_LINE(22);
		std::cout << Std::string("Failed"s) << std::endl;
		HCXX_LINE(23);
		exit(1);
	};
	
	HCXX_LINE(28);
	haxe::_CallStack::CallStack_Impl_::toString(callstack);
}
