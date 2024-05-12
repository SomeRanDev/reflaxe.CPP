#pragma once

#include "Dynamic.h"
namespace haxe {

template<typename T> class Dynamic_haxe_iterators_MapKeyValueIterator;

template<typename K, typename V>
class Dynamic_haxe_iterators_MapKeyValueIterator<haxe::iterators::MapKeyValueIterator<K, V>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		if(name == "hasNext") {
			return Dynamic::makeFunc<haxe::iterators::MapKeyValueIterator<K, V>>(d, [](haxe::iterators::MapKeyValueIterator<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->hasNext());
			});
		} else if(name == "next") {
			return Dynamic::makeFunc<haxe::iterators::MapKeyValueIterator<K, V>>(d, [](haxe::iterators::MapKeyValueIterator<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic(o->next());
			});
		}
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const& d, std::string name) {
		if(name == "map") {
			return Dynamic::unwrap<haxe::iterators::MapKeyValueIterator<K, V>>(d, [](haxe::iterators::MapKeyValueIterator<K, V>* o) {
				return makeDynamic(o->map);
			});
		} else if(name == "keys") {
			return Dynamic::unwrap<haxe::iterators::MapKeyValueIterator<K, V>>(d, [](haxe::iterators::MapKeyValueIterator<K, V>* o) {
				return makeDynamic(o->keys);
			});
		} else if(name == "==") {
			return Dynamic::makeFunc<haxe::iterators::MapKeyValueIterator<K, V>>(d, [](haxe::iterators::MapKeyValueIterator<K, V>* o, std::deque<Dynamic> args) {
				return makeDynamic((*o) == (args[0].asType<haxe::iterators::MapKeyValueIterator<K, V>>()));
			});
		}
		return Dynamic();
	}

	static Dynamic setProp(Dynamic& d, std::string name, Dynamic value) {
		if(name == "map") {
			return Dynamic::unwrap<haxe::iterators::MapKeyValueIterator<K, V>>(d, [value](haxe::iterators::MapKeyValueIterator<K, V>* o) {
				o->map = value.asType<std::shared_ptr<haxe::IMap<K, V>>>();
				return value;
			});
		} else if(name == "keys") {
			return Dynamic::unwrap<haxe::iterators::MapKeyValueIterator<K, V>>(d, [value](haxe::iterators::MapKeyValueIterator<K, V>* o) {
				o->keys = value.asType<std::shared_ptr<Iterator<K>>>();
				return value;
			});
		}
		return Dynamic();
	}
};

}