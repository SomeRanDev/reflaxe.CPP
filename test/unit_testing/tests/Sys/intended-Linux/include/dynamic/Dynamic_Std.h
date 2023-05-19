#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_Std {
public:
	static Dynamic getProp(Dynamic&, std::string) {
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		return Dynamic();
	}
};

}