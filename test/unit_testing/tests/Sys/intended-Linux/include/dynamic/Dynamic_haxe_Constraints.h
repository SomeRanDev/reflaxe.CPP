#pragma once

#include "Dynamic.h"
namespace haxe {

template<typename T> class Dynamic_haxe_IMap;

template<typename K, typename V>
class Dynamic_haxe_IMap<haxe::IMap<K, V>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "get") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->get(args[0].asType<K>()));
			});
		} else if(name == "set") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				o->set(args[0].asType<K>(), args[1].asType<V>());
				return Dynamic();
			});
		} else if(name == "exists") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->exists(args[0].asType<K>()));
			});
		} else if(name == "remove") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->remove(args[0].asType<K>()));
			});
		} else if(name == "keys") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->keys());
			});
		} else if(name == "iterator") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->iterator());
			});
		} else if(name == "keyValueIterator") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->keyValueIterator());
			});
		} else if(name == "copy") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->copy());
			});
		} else if(name == "toString") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->toString());
			});
		} else if(name == "clear") {
			return Dynamic::makeFunc<haxe::IMap<K, V>>(d, [](haxe::IMap<K, V>* o, std::deque<Dynamic> args) {
				o->clear();
				return Dynamic();
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		return Dynamic();
	}
};

}