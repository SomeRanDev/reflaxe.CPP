#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

void Main::main() {
	std::cout << "test/unit_testing/tests/Issue10/Main.hx:17: Hello world from haxe!"s << std::endl;
	Test::test();
	_Main::Main_Fields_::test_me();
}
int Test::test() {
	return 5;
}
std::string _Main::Main_Fields_::test_me() {
	return "hello"s;
}
