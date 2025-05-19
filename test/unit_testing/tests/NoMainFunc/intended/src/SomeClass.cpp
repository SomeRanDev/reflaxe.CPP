#include "SomeClass.h"

#include <iostream>
#include <memory>
#include <string>
#include "SomeClass3.h"

using namespace std::string_literals;

void _SomeClass::SomeClass_Fields_::doSomething() {
	std::cout << "test/unit_testing/tests/NoMainFunc/SomeClass.hx:4: Hello world!"s << std::endl;
	_SomeClass3::SomeClass3_Fields_::doSomething3();
}

int main() {
	return 0;
}
