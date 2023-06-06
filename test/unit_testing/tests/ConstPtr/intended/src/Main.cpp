#include "Main.h"

#include <functional>
#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	Bla a = Bla();
	const Bla* b = &a;
	
	b->check();
	
	std::function<const Bla*()> getA = [&]() mutable {
		return &a;
	};
	
	getA()->check();
}
Bla::Bla():
	_order_id(generate_order_id())
{
	this->a = 123;
}

void Bla::check() const {
	std::cout << "test/unit_testing/tests/ConstPtr/Main.hx:8: works?"s << std::endl;
}
