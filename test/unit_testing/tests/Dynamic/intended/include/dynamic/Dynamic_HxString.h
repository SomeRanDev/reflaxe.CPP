#pragma once

#include "Dynamic.h"
#include <cstddef>
#include <deque>
#include <memory>
#include <optional>

namespace haxe {

class Dynamic_std_string {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "indexOf") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic(o->find(args[0].asType<std::string>(), (std::size_t)(args[1].asType<int>())));
			});
		} else if(name == "substr") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic(o->substr(args[0].asType<int>(), args[1].asType<int>()));
			});
		} else if(name == "lastIndexOf") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic(o->rfind(args[0].asType<std::string>(), (std::size_t)(args[1].asType<int>())));
			});
		} else if(name == "charAt") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic(std::string(1, (*o)[args[0].asType<int>()]));
			});
		} else if(name == "toString") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic((*o));
			});
		} else if(name == "charCodeAt") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic((*o)[args[0].asType<int>()]);
			});
		} else if(name == "toUpperCase") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxString::toUpperCase((*o));
				};
				return makeDynamic(result());
			});
		} else if(name == "toLowerCase") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return HxString::toLowerCase((*o));
				};
				return makeDynamic(result());
			});
		} else if(name == "split") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto delimiter = args[0].asType<std::string>();
					{
						return HxString::split((*o), delimiter);
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "substring") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					auto startIndex = args[0].asType<int>();
					auto endIndex = args[1].asType<int>();
					{
						std::string tempResult;
						
						{
							if(endIndex < 0) {
								tempResult = o->substr(startIndex);
							} else {
								tempResult = o->substr(startIndex, endIndex - startIndex);
							};
						};
						
						return tempResult;
					}
				};
				return makeDynamic(result());
			});
		} else if(name == "c_str") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic(o->c_str());
			});
		} else if(name == "data") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic(o->data());
			});
		} else if(name == "at") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic(o->at(args[0].asType<int>()));
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "length") {
			return Dynamic::unwrap<std::string>(d, [](std::string* o) {
				return makeDynamic(o->size());
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<std::string>(d, [](std::string* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<std::string>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		return Dynamic();
	}
};

}