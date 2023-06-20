#include "Main.h"

#include <cstdlib>

int _Main::Main_Fields_::exitCode = 0;

void _Main::Main_Fields_::assert(bool v) {
	if(!v) {
		_Main::Main_Fields_::exitCode = 1;
	};
}

void _Main::Main_Fields_::main() {
	int* a = nullptr;

	_Main::Main_Fields_::assert((a == nullptr));

	int b = 123;

	a = &b;
	_Main::Main_Fields_::assert(!(a == nullptr));

	int* c = a;

	_Main::Main_Fields_::assert((*a) == (*c));
	_Main::Main_Fields_::assert((a == c));
	_Main::Main_Fields_::assert(!(a != c));
	b = 100;
	_Main::Main_Fields_::assert((*a) == b);
	_Main::Main_Fields_::assert((*c) == b);
	b = 200;
	_Main::Main_Fields_::assert((*a) == b);
	_Main::Main_Fields_::assert((*c) == b);
	_Main::Main_Fields_::assert((*a) == 200);

	int* d = &(b);

	_Main::Main_Fields_::assert(!(d == nullptr));

	if(_Main::Main_Fields_::exitCode != 0) {
		exit(_Main::Main_Fields_::exitCode);
	};
}
