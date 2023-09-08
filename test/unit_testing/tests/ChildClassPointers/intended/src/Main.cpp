#include "Main.h"

#include <cstdlib>
#include <memory>

int _Main::Main_Fields_::returnCode = 0;

void _Main::Main_Fields_::assert(bool v) {
	if(!v) {
		_Main::Main_Fields_::returnCode = 1;
	};
}

void _Main::Main_Fields_::main() {
	A* a = nullptr;
	B* b = new B();

	a = b;

	static_cast<void>(std::make_shared<C>());

	_Main::Main_Fields_::assert((a == b));

	if(_Main::Main_Fields_::returnCode != 0) {
		exit(_Main::Main_Fields_::returnCode);
	};
}
B::B():
	_order_id(generate_order_id())
{
	this->val = 0;
}
C::C():
	_order_id(generate_order_id())
{
	this->val = 100;
}
