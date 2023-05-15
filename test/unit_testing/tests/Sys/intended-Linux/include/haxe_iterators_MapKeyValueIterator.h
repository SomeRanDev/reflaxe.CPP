#pragma once

#include <memory>
#include "_AnonStructs.h"
#include "_HaxeUtils.h"
#include "haxe_Constraints.h"
#include "StdTypes.h"

namespace haxe::iterators {

template<typename K, typename V>
class MapKeyValueIterator {
public:
	std::shared_ptr<haxe::IMap<K, V>> map;
	
	std::shared_ptr<Iterator<K>> keys;

	MapKeyValueIterator(std::shared_ptr<haxe::IMap<K, V>> map):
		_order_id(generate_order_id())
	{
		this->map = map;
		this->keys = map->keys();
	}
	
	bool hasNext() {
		return this->keys->hasNext();
	}
	
	std::shared_ptr<haxe::AnonStruct0<K, V>> next() {
		K key = this->keys->next();
		
		return haxe::shared_anon<haxe::AnonStruct0<K, V>>(key, this->map->get(key).value());
	}
	
	HX_COMPARISON_OPERATORS(MapKeyValueIterator<K, V>)
};

}


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<typename K, typename V> struct _class<haxe::iterators::MapKeyValueIterator<K, V>> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<4, 0> data {"MapKeyValueIterator", { "map", "keys", "hasNext", "next" }, {}, false};
	};
}
