#pragma once

#include <deque>
#include <memory>

namespace haxe::iterators {

template<typename T>
class ArrayIterator {
public:
	std::shared_ptr<std::deque<T>> array;
	
	int current;

	ArrayIterator(std::shared_ptr<std::deque<T>> array) {
		this->current = 0;
		this->array = array;
	}
	
	bool hasNext() {
		return this->current < this->array->size();
	}
	
	T next() {
		return (*this->array)[this->current++];
	}
};

}
