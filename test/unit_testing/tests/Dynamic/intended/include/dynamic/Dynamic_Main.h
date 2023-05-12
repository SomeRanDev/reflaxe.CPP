#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic__Main_Main_Fields_ {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "main") {
			return Dynamic::makeFunc<_Main::Main_Fields_>(d, [](_Main::Main_Fields_* o, std::deque<Dynamic> args) {
				o->main();
				return Dynamic();
			});
		}
		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {

		throw "Property does not exist";
	}
};

}
namespace haxe {

class Dynamic_Test {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "a") {
			return Dynamic::unwrap<Test>(d, [](Test* o) {
				return makeDynamic(o->a);
			});
		} else 		if(name == "test") {
			return Dynamic::makeFunc<Test>(d, [](Test* o, std::deque<Dynamic> args) {
				o->test();
				return Dynamic();
			});
		} else 		if(name == "toString") {
			return Dynamic::makeFunc<Test>(d, [](Test* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toString());
			});
		}
		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "a") {
			return Dynamic::unwrap<Test>(d, [value](Test* o) {
				o->a = value.asType<int>();
				return value;
			});
		}
		throw "Property does not exist";
	}
};

}