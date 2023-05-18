#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_StringBuf {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "b") {
			return Dynamic::unwrap<StringBuf>(d, [](StringBuf* o) {
				return makeDynamic(o->b);
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