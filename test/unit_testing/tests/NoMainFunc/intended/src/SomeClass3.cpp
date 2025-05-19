#include "SomeClass3.h"

#include <iostream>
#include <string>

using namespace std::string_literals;

void _SomeClass3::SomeClass3_Fields_::doSomething3() {
	std::cout << "test/unit_testing/tests/NoMainFunc/SomeClass3.hx:4: This should generate but not SomeClass2"s << std::endl;
}
