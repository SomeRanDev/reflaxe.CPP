#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_NativeStackTrace {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "saveStack") {
			return Dynamic::makeFunc<haxe::NativeStackTrace>(d, [](haxe::NativeStackTrace* o, std::deque<Dynamic> args) {
				o->saveStack(args[0].asType<std::any>());
				return Dynamic();
			});
		} else if(name == "callStack") {
			return Dynamic::makeFunc<haxe::NativeStackTrace>(d, [](haxe::NativeStackTrace* o, std::deque<Dynamic> args) {
				return makeDynamic(o->callStack());
			});
		} else if(name == "exceptionStack") {
			return Dynamic::makeFunc<haxe::NativeStackTrace>(d, [](haxe::NativeStackTrace* o, std::deque<Dynamic> args) {
				return makeDynamic(o->exceptionStack());
			});
		} else if(name == "toHaxe") {
			return Dynamic::makeFunc<haxe::NativeStackTrace>(d, [](haxe::NativeStackTrace* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toHaxe(args[0].asType<std::shared_ptr<std::deque<haxe::NativeStackItemData>>>(), args[1].asType<int>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		
		return Dynamic();
	}
};

}