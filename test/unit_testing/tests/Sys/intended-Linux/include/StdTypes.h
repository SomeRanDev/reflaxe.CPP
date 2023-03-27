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
	template<typename T_>
	Iterator(T_ o) {
		hasNext = [=]() { return haxe::unwrap(o).hasNext(); };
		next = [=]() { return haxe::unwrap(o).next(); };
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
using KeyValueIterator = std::shared_ptr<Iterator<std::shared_ptr<haxe::AnonStruct1<K, V>>>>;

