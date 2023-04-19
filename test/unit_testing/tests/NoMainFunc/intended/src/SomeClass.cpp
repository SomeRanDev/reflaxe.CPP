#include "SomeClass.h"

#include <iostream>
#include <string>

using namespace std::string_literals;

void _SomeClass::SomeClass_Fields_::doSomething() {
	std::cout << "test/unit_testing/tests/NoMainFunc/SomeClass.hx:4: Hello world!"s << std::endl;
}

int main() {
	return 0;
}
