#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_Sys_GetEnv {
public:
	static Dynamic getProp(Dynamic&, std::string) {
		
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
	}
};

}
namespace haxe {

class Dynamic_Sys_Environment {
public:
	static Dynamic getProp(Dynamic&, std::string) {
		
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
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
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "_args") {
			return Dynamic::unwrap<Sys_Args>(d, [value](Sys_Args* o) {
				o->_args = value.asType<std::deque<std::string>>();
				return value;
			});
		}
		return Dynamic();
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
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "_startTime") {
			return Dynamic::unwrap<Sys_CpuTime>(d, [value](Sys_CpuTime* o) {
				o->_startTime = value.asType<std::chrono::time_point<std::chrono::system_clock>>();
				return value;
			});
		}
		return Dynamic();
	}
};

}