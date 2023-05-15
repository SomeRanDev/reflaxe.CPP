#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_Sys_GetEnv {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "getEnv") {
			return Dynamic::makeFunc<Sys_GetEnv>(d, [](Sys_GetEnv* o, std::deque<Dynamic> args) {
				return makeDynamic(o->getEnv(args[0].asType<std::string>()));
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

class Dynamic_Sys_Environment {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "environment") {
			return Dynamic::makeFunc<Sys_Environment>(d, [](Sys_Environment* o, std::deque<Dynamic> args) {
				return makeDynamic(o->environment());
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

class Dynamic_Sys_Args {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "_args") {
			return Dynamic::unwrap<Sys_Args>(d, [](Sys_Args* o) {
				return makeDynamic(o->_args);
			});
		} else 		if(name == "setupArgs") {
			return Dynamic::makeFunc<Sys_Args>(d, [](Sys_Args* o, std::deque<Dynamic> args) {
				o->setupArgs(args[0].asType<int>(), args[1].asType<const char**>());
				return Dynamic();
			});
		} else 		if(name == "args") {
			return Dynamic::makeFunc<Sys_Args>(d, [](Sys_Args* o, std::deque<Dynamic> args) {
				return makeDynamic(o->args());
			});
		}
		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "_args") {
			return Dynamic::unwrap<Sys_Args>(d, [value](Sys_Args* o) {
				o->_args = value.asType<std::deque<std::string>>();
				return value;
			});
		}
		throw "Property does not exist";
	}
};

}
namespace haxe {

class Dynamic_Sys_CpuTime {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "_startTime") {
			return Dynamic::unwrap<Sys_CpuTime>(d, [](Sys_CpuTime* o) {
				return makeDynamic(o->_startTime);
			});
		} else 		if(name == "setupStart") {
			return Dynamic::makeFunc<Sys_CpuTime>(d, [](Sys_CpuTime* o, std::deque<Dynamic> args) {
				o->setupStart();
				return Dynamic();
			});
		} else 		if(name == "cpuTime") {
			return Dynamic::makeFunc<Sys_CpuTime>(d, [](Sys_CpuTime* o, std::deque<Dynamic> args) {
				return makeDynamic(o->cpuTime());
			});
		}
		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "_startTime") {
			return Dynamic::unwrap<Sys_CpuTime>(d, [value](Sys_CpuTime* o) {
				o->_startTime = value.asType<std::chrono::time_point<std::chrono::system_clock>>();
				return value;
			});
		}
		throw "Property does not exist";
	}
};

}