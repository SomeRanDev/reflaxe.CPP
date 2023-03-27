#pragma once

#include <deque>
#include <memory>

namespace haxe::iterators {

template<typename T>
class ArrayIterator {
public:
	std::shared_ptr<std::deque<T>> array;
	
	int current;

	ArrayIterator(std::shared_ptr<std::deque<T>> array): _order_id(generate_order_id()) {
		this->current = 0;
		this->array = array;
	}
	
	bool hasNext() {
		return this->current < this->array->size();
	}
	
	T next() {
		return (*this->array)[this->current++];
	}
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const ArrayIterator<T>& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const ArrayIterator<T>& other) const {
		return _order_id < other._order_id;
	}
};

}
