#pragma once

#include "Dynamic.h"
namespace haxe {

template<typename T> class Dynamic_haxe_ds_StringMap;

template<typename T>
class Dynamic_haxe_ds_StringMap<haxe::ds::StringMap<T>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "set") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				o->set(args[0].asType<std::string>(), args[1].asType<T>());
				return Dynamic();
			});
		} else if(name == "get") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->get(args[0].asType<std::string>()));
			});
		} else if(name == "exists") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->exists(args[0].asType<std::string>()));
			});
		} else if(name == "remove") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->remove(args[0].asType<std::string>()));
			});
		} else if(name == "keys") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->keys());
			});
		} else if(name == "iterator") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->iterator());
			});
		} else if(name == "keyValueIterator") {
			return Dynamic::makeFuncShared<haxe::ds::StringMap<T>>(d, [](std::shared_ptr<haxe::ds::StringMap<T>> o, std::deque<Dynamic> args) {
				auto result = [o, args] {
					return std::make_shared<haxe::iterators::MapKeyValueIterator<std::string, T>>(o);
				};
				return makeDynamic(result());
			});
		} else if(name == "copyOG") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->copyOG());
			});
		} else if(name == "toString") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toString());
			});
		} else if(name == "clear") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				o->clear();
				return Dynamic();
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "m") {
			return Dynamic::unwrap<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o) {
				return makeDynamic(o->m);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<haxe::ds::StringMap<T>>(d, [](haxe::ds::StringMap<T>* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<haxe::ds::StringMap<T>>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "m") {
			return Dynamic::unwrap<haxe::ds::StringMap<T>>(d, [value](haxe::ds::StringMap<T>* o) {
				o->m = value.asType<std::map<std::string, T>>();
				return value;
			});
		}
		return Dynamic();
	}
};

}