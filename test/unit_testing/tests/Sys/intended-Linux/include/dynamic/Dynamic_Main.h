#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_Main {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "a") {
			return Dynamic::unwrap<Main>(d, [](Main* o) {
				return makeDynamic(o->a);
			});
		} else if(name == "returnCode") {
			return Dynamic::unwrap<Main>(d, [](Main* o) {
				return makeDynamic(o->returnCode);
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "a") {
			return Dynamic::unwrap<Main>(d, [value](Main* o) {
				o->a = value.asType<int>();
				return value;
			});
		} else if(name == "returnCode") {
			return Dynamic::unwrap<Main>(d, [value](Main* o) {
				o->returnCode = value.asType<int>();
				return value;
			});
		}
		return Dynamic();
	}
};

}