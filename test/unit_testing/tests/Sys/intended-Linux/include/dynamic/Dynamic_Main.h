#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_Main {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "returnCode") {
			return Dynamic::unwrap<Main>(d, [](Main* o) {
				return makeDynamic(o->returnCode);
			});
		} else if(name == "a") {
			return Dynamic::unwrap<Main>(d, [](Main* o) {
				return makeDynamic(o->a);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<Main>(d, [](Main* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<Main>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "returnCode") {
			return Dynamic::unwrap<Main>(d, [value](Main* o) {
				o->returnCode = value.asType<int>();
				return value;
			});
		} else if(name == "a") {
			return Dynamic::unwrap<Main>(d, [value](Main* o) {
				o->a = value.asType<int>();
				return value;
			});
		}
		return Dynamic();
	}
};

}