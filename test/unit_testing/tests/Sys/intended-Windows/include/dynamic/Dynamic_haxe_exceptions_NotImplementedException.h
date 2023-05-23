#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_exceptions_NotImplementedException {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "==") {
			return Dynamic::makeFunc<haxe::exceptions::NotImplementedException>(d, [](haxe::exceptions::NotImplementedException* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<haxe::exceptions::NotImplementedException>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		return Dynamic();
	}
};

}