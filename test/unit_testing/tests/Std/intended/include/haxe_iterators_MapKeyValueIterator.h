#pragma once

#include <memory>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "StdTypes.h"

namespace haxe::iterators {

template<typename K, typename V>
class MapKeyValueIterator {
public:
	std::shared_ptr<haxe::IMap<K, V>> map;
	
	std::shared_ptr<Iterator<K>> keys;

	MapKeyValueIterator(std::shared_ptr<haxe::IMap<K, V>> map): _order_id(generate_order_id()) {
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
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const MapKeyValueIterator<K, V>& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const MapKeyValueIterator<K, V>& other) const {
		return _order_id < other._order_id;
	}
};

}


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<typename K, typename V> struct _class<haxe::iterators::MapKeyValueIterator<K, V>> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<4, 0> data {"MapKeyValueIterator", { "map", "keys", "hasNext", "next" }, {}};
	};
}
