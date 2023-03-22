#pragma once

#include "_AnonUtils.h"

#include <functional>
#include <optional>

namespace haxe {

// { key: KeyValueIterator.K, value: KeyValueIterator.V }
template<typename K, typename V>
struct AnonStruct2 {

	// default constructor
	AnonStruct2() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct2(T o):
		key(o.key), value(o.value)
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


// { key: Int, value: haxe.ds.IntMap.T }
template<typename T>
struct AnonStruct1 {

	// default constructor
	AnonStruct1() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct1(T o):
		key(o.key), value(o.value)
	{}
	
	// construct fields directly
	static AnonStruct1 make(int key, T value) {
		AnonStruct1 result;
		result.key = key;
		result.value = value;
		return result;
	}

	// fields
	int key;
	T value;
};


// { next: () -> { value : haxe.ds.IntMap.T, key : Int }, hasNext: () -> Bool }
template<typename T>
struct AnonStruct0 {

	// default constructor
	AnonStruct0() {}
	
	// auto-construct from any object's fields
	template<typename T>
	AnonStruct0(T o) {
		next = [&o]() { return o.next(); };
		hasNext = [&o]() { return o.hasNext(); };
	}
	
	// construct fields directly
	static AnonStruct0 make(std::function<std::shared_ptr<haxe::AnonStruct1<T>>()> next, std::function<bool()> hasNext) {
		AnonStruct0 result;
		result.next = next;
		result.hasNext = hasNext;
		return result;
	}

	// fields
	std::function<std::shared_ptr<haxe::AnonStruct1<T>>()> next;
	std::function<bool()> hasNext;
};

}