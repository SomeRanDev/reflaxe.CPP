#pragma once

#include "Dynamic.h"
namespace haxe {

class Dynamic_haxe_Exception {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "_message") {
			return Dynamic::unwrap<haxe::Exception>(d, [](haxe::Exception* o) {
				return makeDynamic(o->_message);
			});
		} else if(name == "_previous") {
			return Dynamic::unwrap<haxe::Exception>(d, [](haxe::Exception* o) {
				return makeDynamic(o->_previous);
			});
		} else if(name == "get_message") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->get_message());
			});
		} else if(name == "get_stack") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->get_stack());
			});
		} else if(name == "get_previous") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->get_previous());
			});
		} else if(name == "get_native") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->get_native());
			});
		} else if(name == "unwrap") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->unwrap());
			});
		} else if(name == "toString") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toString());
			});
		} else if(name == "details") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->details());
			});
		} else if(name == "caught") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->caught(args[0].asType<std::any>()));
			});
		} else if(name == "thrown") {
			return Dynamic::makeFunc<haxe::Exception>(d, [](haxe::Exception* o, std::deque<Dynamic> args) {
				return makeDynamic(o->thrown(args[0].asType<std::any>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "_message") {
			return Dynamic::unwrap<haxe::Exception>(d, [value](haxe::Exception* o) {
				o->_message = value.asType<std::string>();
				return value;
			});
		} else if(name == "_previous") {
			return Dynamic::unwrap<haxe::Exception>(d, [value](haxe::Exception* o) {
				o->_previous = value.asType<std::optional<std::shared_ptr<haxe::Exception>>>();
				return value;
			});
		}
		return Dynamic();
	}
};

}