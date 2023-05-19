#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_Log {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "formatOutput") {
			return Dynamic::makeFunc<haxe::Log>(d, [](haxe::Log* o, std::deque<Dynamic> args) {
				return makeDynamic(o->formatOutput(args[0].asType<std::string>(), args[1].asType<std::optional<std::shared_ptr<haxe::PosInfos>>>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
	}
};

}