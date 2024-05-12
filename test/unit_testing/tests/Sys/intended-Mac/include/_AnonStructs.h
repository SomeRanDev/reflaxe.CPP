#pragma once

#include "_AnonUtils.h"

#include <optional>

namespace haxe {

// { key: haxe.iterators.MapKeyValueIterator.K, value: haxe.iterators.MapKeyValueIterator.V }
template<typename K, typename V>
struct AnonStruct0 {

	// default constructor
	AnonStruct0() {}

	// auto-construct from any object's fields
	template<typename T>
	AnonStruct0(T o):
		key(haxe::unwrap(o).key),
		value(haxe::unwrap(o).value)
	{}

	// construct fields directly
	static AnonStruct0 make(K key, V value) {
		AnonStruct0 result;
		result.key = key;
		result.value = value;
		return result;
	}

	// fields
	K key;
	V value;
};

}