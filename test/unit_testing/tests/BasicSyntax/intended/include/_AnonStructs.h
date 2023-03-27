#pragma once

#include "_AnonUtils.h"

#include <optional>

namespace haxe {

// { len: Int, pos: Int }
struct AnonStruct0 {

	// default constructor
	AnonStruct0() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct0(T o):
		len(haxe::unwrap(o).len),
		pos(haxe::unwrap(o).pos)
	{}
	
	// construct fields directly
	static AnonStruct0 make(int len, int pos) {
		AnonStruct0 result;
		result.len = len;
		result.pos = pos;
		return result;
	}

	// fields
	int len;
	int pos;
};


// { key: haxe.iterators.MapKeyValueIterator.K, value: haxe.iterators.MapKeyValueIterator.V }
template<typename K, typename V>
struct AnonStruct1 {

	// default constructor
	AnonStruct1() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct1(T o):
		key(haxe::unwrap(o).key),
		value(haxe::unwrap(o).value)
	{}
	
	// construct fields directly
	static AnonStruct1 make(K key, V value) {
		AnonStruct1 result;
		result.key = key;
		result.value = value;
		return result;
	}

	// fields
	K key;
	V value;
};


// { key: KeyValueIterator.K, value: KeyValueIterator.V }
template<typename K, typename V>
struct AnonStruct2 {

	// default constructor
	AnonStruct2() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct2(T o):
		key(haxe::unwrap(o).key),
		value(haxe::unwrap(o).value)
	{}
	
	// construct fields directly
	static AnonStruct2 make(K key, V value) {
		AnonStruct2 result;
		result.key = key;
		result.value = value;
		return result;
	}

	// fields
	K key;
	V value;
};

}