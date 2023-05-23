#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_StringBuf {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "b") {
			return Dynamic::unwrap<StringBuf>(d, [](StringBuf* o) {
				return makeDynamic(o->b);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<StringBuf>(d, [](StringBuf* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<StringBuf>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "b") {
			return Dynamic::unwrap<StringBuf>(d, [value](StringBuf* o) {
				o->b = value.asType<std::string>();
				return value;
			});
		}
		return Dynamic();
	}
};

}