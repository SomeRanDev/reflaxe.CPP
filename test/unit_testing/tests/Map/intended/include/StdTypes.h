#pragma once

#include "_AnonStructs.h"
#include <functional>
#include <memory>

// { hasNext: () -> Bool, next: () -> Iterator.T }
template<typename T>
struct Iterator {

	// default constructor
	Iterator() {}
	
	// auto-construct from any object's fields
	template<typename T>
	Iterator(T o) {
		hasNext = [&o]() { return o.hasNext(); };
		next = [&o]() { return o.next(); };
	}
	
	// construct fields directly
	static Iterator make(std::function<bool()> hasNext, std::function<T()> next) {
		Iterator result;
		result.hasNext = hasNext;
		result.next = next;
		return result;
	}

	// fields
	std::function<bool()> hasNext;
	std::function<T()> next;
};

template<typename K, typename V>
using KeyValueIterator = Iterator<std::shared_ptr<haxe::AnonStruct2<K, V>>>;

