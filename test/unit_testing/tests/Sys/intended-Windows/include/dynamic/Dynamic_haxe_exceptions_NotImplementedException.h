#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_exceptions_NotImplementedException {
public:
	static Dynamic getProp(Dynamic&, std::string) {

		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {

		throw "Property does not exist";
	}
};

}