#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_exceptions_NotImplementedException {
public:
	static Dynamic getProp(Dynamic&, std::string) {
		
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
	}
};

}