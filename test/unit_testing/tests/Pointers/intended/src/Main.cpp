#include "Main.h"

#include <cstdlib>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Log.h"

using namespace std::string_literals;

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
	haxe::Log::trace(*(d), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Pointers/Main.hx"s, 41, "main"s));

	if(_Main::Main_Fields_::exitCode != 0) {
		exit(_Main::Main_Fields_::exitCode);
	};
}
