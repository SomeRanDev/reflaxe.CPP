#include "Main.h"

#include <cstdlib>
#include <string>

using namespace std::string_literals;

int _Main::Main_Fields_::returnCode = 0;

void _Main::Main_Fields_::assert(bool b) {
	if(!b) {
		_Main::Main_Fields_::returnCode = 1;
	};
}

void _Main::Main_Fields_::main() {
	int a = 123;
	
	switch(a) {
		case 1: {
			_Main::Main_Fields_::assert(false);
			break;
		}
		case 2: {
			_Main::Main_Fields_::assert(false);
			break;
		}
		case 123: {
			_Main::Main_Fields_::assert(true);
			break;
		}
	};
	switch(a) {
		case 1: {
			_Main::Main_Fields_::assert(false);
			break;
		}
		case 2: {
			_Main::Main_Fields_::assert(false);
			break;
		}
		case 3: {
			_Main::Main_Fields_::assert(false);
			break;
		}
		default: {
			_Main::Main_Fields_::assert(true);
			break;
		}
	};
	
	std::string str = "Hello"s;
	
	auto __temp = str;
	switch(__temp.size()) {
		case 9: {
			if(__temp == "Blablabla"s) {
				_Main::Main_Fields_::assert(false);
			}
			break;
		}
		case 5: {
			if(__temp == "Hello"s) {
				_Main::Main_Fields_::assert(true);
			}
			break;
		}
		case 7: {
			if(__temp == "Goodbye"s) {
				_Main::Main_Fields_::assert(false);
			}
			break;
		}
	};
	
	if(_Main::Main_Fields_::returnCode != 0) {
		exit(_Main::Main_Fields_::returnCode);
	};
}
