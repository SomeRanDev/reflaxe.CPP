#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_Std {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const&, std::string) {
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		return Dynamic();
	}
};

}