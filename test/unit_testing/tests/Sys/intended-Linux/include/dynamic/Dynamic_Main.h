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
		} else if(name == "assert") {
			return Dynamic::makeFunc<Main>(d, [](Main* o, std::deque<Dynamic> args) {
				o->assert(args[0].asType<bool>(), args[1].asType<std::optional<std::shared_ptr<haxe::PosInfos>>>());
				return Dynamic();
			});
		} else if(name == "main") {
			return Dynamic::makeFunc<Main>(d, [](Main* o, std::deque<Dynamic> args) {
				o->main();
				return Dynamic();
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