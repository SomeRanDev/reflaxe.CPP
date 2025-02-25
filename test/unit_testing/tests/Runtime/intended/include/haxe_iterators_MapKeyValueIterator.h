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

	MapKeyValueIterator(std::shared_ptr<haxe::IMap<K, V>> map2):
		_order_id(generate_order_id())
	{
		this->map = map2;
		this->keys = map2->keys();
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
