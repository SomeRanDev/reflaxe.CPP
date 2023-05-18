#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_exceptions_PosException {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "posInfos") {
			return Dynamic::unwrap<haxe::exceptions::PosException>(d, [](haxe::exceptions::PosException* o) {
				return makeDynamic(o->posInfos);
			});
		} else if(name == "toString") {
			return Dynamic::makeFunc<haxe::exceptions::PosException>(d, [](haxe::exceptions::PosException* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toString());
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
	}
};

}