#include "Main.h"

#include <functional>
#include <iostream>
#include <memory>
#include <string>

using namespace std::string_literals;

Main::Main():
	_order_id(generate_order_id())
{
	this->fn = [&]() mutable {
		std::cout << "test/unit_testing/tests/Issue38_CallFindFuncDataOnVar/Main.hx:12: do something"s << std::endl;
	};
	this->fn();
}

void Main::main() {
	static_cast<void>(std::make_shared<Main>());
}
