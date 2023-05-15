#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe__CallStack_CallStack_Impl_ {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "toString") {
			return Dynamic::makeFunc<haxe::_CallStack::CallStack_Impl_>(d, [](haxe::_CallStack::CallStack_Impl_* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toString(args[0].asType<std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>>>()));
			});
		} else 		if(name == "itemToString") {
			return Dynamic::makeFunc<haxe::_CallStack::CallStack_Impl_>(d, [](haxe::_CallStack::CallStack_Impl_* o, std::deque<Dynamic> args) {
				o->itemToString(args[0].asType<std::shared_ptr<StringBuf>>(), args[1].asType<std::shared_ptr<haxe::StackItem>>());
				return Dynamic();
			});
		}
		throw "Property does not exist";
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {

		throw "Property does not exist";
	}
};

}