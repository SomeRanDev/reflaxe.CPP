#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_exceptions_NotImplementedException {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {

		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {

		throw "Property does not exist";
	}
};

}