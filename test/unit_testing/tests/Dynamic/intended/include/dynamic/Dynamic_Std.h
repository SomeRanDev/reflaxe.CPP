#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_Std: public Dynamic {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "string") {
			return Dynamic::makeFunc<Std>(d, [](Std* o, std::deque<Dynamic> args) {
				return makeDynamic(o->string(args[0].asType<haxe::DynamicToString>()));
			});
		} else 		if(name == "parseInt") {
			return Dynamic::makeFunc<Std>(d, [](Std* o, std::deque<Dynamic> args) {
				return makeDynamic(o->parseInt(args[0].asType<std::string>()));
			});
		} else 		if(name == "parseFloat") {
			return Dynamic::makeFunc<Std>(d, [](Std* o, std::deque<Dynamic> args) {
				return makeDynamic(o->parseFloat(args[0].asType<std::string>()));
			});
		}
		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {

		throw "Property does not exist";
	}
};

}