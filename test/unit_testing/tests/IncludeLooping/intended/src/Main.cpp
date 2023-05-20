#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "Other2.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	std::cout << "test/unit_testing/tests/IncludeLooping/Main.hx:10: Hello world!"s << std::endl;
	
	std::shared_ptr<Main> m = std::make_shared<Main>();
	static_cast<void>(std::make_shared<Other2>(m));
}
Main::Main():
	_order_id(generate_order_id())
{
	
}
