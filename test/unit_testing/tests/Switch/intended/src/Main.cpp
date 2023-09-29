#include "Main.h"

#include <cstdlib>
#include <memory>
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
		default: {}
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
		default: {}
	};

	int tempNumber = 0;

	switch(a) {
		case 111: {
			tempNumber = 222;
			break;
		}
		case 222: {
			tempNumber = 444;
			break;
		}
		default: {
			tempNumber = 0;
			break;
		}
	};

	int result = tempNumber;

	_Main::Main_Fields_::assert(result == 0);

	std::shared_ptr<Test> myEnum = Test::Two();
	int tempNumber1 = 0;

	switch(myEnum->index) {
		case 0: {
			tempNumber1 = 1;
			break;
		}
		case 1: {
			tempNumber1 = 0;
			break;
		}
		case 2: {
			tempNumber1 = 3;
			break;
		}
		case 3: {
			tempNumber1 = 4;
			break;
		}
		default: {}
	};

	int result2 = tempNumber1;

	_Main::Main_Fields_::assert(result2 == 0);

	if(_Main::Main_Fields_::returnCode != 0) {
		exit(_Main::Main_Fields_::returnCode);
	};
}
