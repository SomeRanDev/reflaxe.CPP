#include "Main.h"

#include <memory>

void _Main::Main_Fields_::main() {
	static_cast<void>(std::make_shared<Child>());
}
Child::Child():
	Base(), _order_id(generate_order_id())
{

}

void Child::overridden(std::string a) {

}
Base::Base():
	_order_id(generate_order_id())
{

}

void Base::overridden(std::string a) {

}

void Base::dummy(std::optional<int> optional) {

}
