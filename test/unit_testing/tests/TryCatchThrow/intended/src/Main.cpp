#include "Main.h"

#include <cstdlib>
#include <exception>
#include <functional>
#include <iostream>
#include <memory>
#include <stdexcept>
#include <string>
#include "haxe_Exception.h"
#include "Std.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	std::function<void(bool)> assert = [&](bool b) mutable {
		if(!b) {
			std::cout << Std::string("Assert failed"s) << std::endl;
			exit(1);
		};
	};
	std::string msg = "a message"s;
	
	try {
		throw haxe::Exception(msg);
	} catch(haxe::Exception& e) {
		assert(e.get_message() == msg);
	};
	try {
		throw haxe::Exception(msg);
	} catch(haxe::Exception& e) {
		assert(e.get_message() == msg);
	};
	try {
		
		throw std::runtime_error("test");
	} catch(std::exception& e) {
		assert(std::string(e.what()) == "test"s);
	};
}
