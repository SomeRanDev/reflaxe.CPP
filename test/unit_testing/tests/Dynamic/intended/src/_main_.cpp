#include <memory>
#include "Main.h"

int main(int argc, const char* argv[]) {
	_Main::Main_Fields_::main();
	return 0;
}


// Implementation for haxe::makeError from dynamic/Dynamic.h


void haxe::makeError(const char* msg) {
	throw haxe::Exception(msg);
}