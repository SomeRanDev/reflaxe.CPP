#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic__Main_Main_Fields_ {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "returnCode") {
			return Dynamic::unwrap<_Main::Main_Fields_>(d, [](_Main::Main_Fields_* o) {
				return makeDynamic(o->returnCode);
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "returnCode") {
			return Dynamic::unwrap<_Main::Main_Fields_>(d, [value](_Main::Main_Fields_* o) {
				o->returnCode = value.asType<int>();
				return value;
			});
		}
		return Dynamic();
	}
};

}
namespace haxe {

class Dynamic_Test {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "test") {
			return Dynamic::makeFunc<Test>(d, [](Test* o, std::deque<Dynamic> args) {
				o->test();
				return Dynamic();
			});
		} else if(name == "toString") {
			return Dynamic::makeFunc<Test>(d, [](Test* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toString());
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "a") {
			return Dynamic::unwrap<Test>(d, [](Test* o) {
				return makeDynamic(o->a);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<Test>(d, [](Test* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<Test>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "a") {
			return Dynamic::unwrap<Test>(d, [value](Test* o) {
				o->a = value.asType<int>();
				return value;
			});
		}
		return Dynamic();
	}
};

}
namespace haxe {

template<typename T> class Dynamic_HasParam;

template<typename T>
class Dynamic_HasParam<HasParam<T>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "test") {
			return Dynamic::makeFunc<HasParam<T>>(d, [](HasParam<T>* o, std::deque<Dynamic> args) {
				o->test();
				return Dynamic();
			});
		} else if(name == "getT") {
			return Dynamic::makeFunc<HasParam<T>>(d, [](HasParam<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->getT());
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "t") {
			return Dynamic::unwrap<HasParam<T>>(d, [](HasParam<T>* o) {
				return makeDynamic(o->t);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<HasParam<T>>(d, [](HasParam<T>* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<HasParam<T>>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "t") {
			return Dynamic::unwrap<HasParam<T>>(d, [value](HasParam<T>* o) {
				o->t = value.asType<T>();
				return value;
			});
		}
		return Dynamic();
	}
};

}