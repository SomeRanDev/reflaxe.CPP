#include <memory>
#include "Main.h"

int main(int, const char**) {
	_Main::Main_Fields_::main();
	return 0;
}


// Implementation for haxe::makeError from dynamic/Dynamic.h
#include "haxe_Exception.h"

void haxe::makeError(const char* msg) {
	throw haxe::Exception(msg);
}