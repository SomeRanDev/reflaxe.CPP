#include "Main.h"

#include <iostream>
#include <string>

using namespace std::string_literals;

Test _Main::Main_Fields_::t;

void _Main::Main_Fields_::main() {
	std::cout << "test/unit_testing/tests/MemoryManagement/Main.hx:14: Hello world!"s << std::endl;
	_Main::Main_Fields_::t = Test();
}

Test* _Main::Main_Fields_::getTest() {
	return &_Main::Main_Fields_::t;
}
Test::Test():
	_order_id(generate_order_id())
{
	this->a = 123;
}
