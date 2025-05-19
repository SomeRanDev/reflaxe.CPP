#pragma once

#include <deque>
#include <memory>
#include "_HaxeUtils.h"

namespace haxe::iterators {

template<typename T>
class ArrayIterator {
public:
	std::shared_ptr<std::deque<T>> array;
	int current;

	ArrayIterator(std::shared_ptr<std::deque<T>> array2):
		_order_id(generate_order_id())
	{
		this->current = 0;
		this->array = array2;
	}
	bool hasNext() {
		return this->current < (int)(this->array->size());
	}
	T next() {
		return (*this->array)[this->current++];
	}

	HX_COMPARISON_OPERATORS(ArrayIterator<T>)
};

}


#include "dynamic/Dynamic_haxe_iterators_ArrayIterator.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<typename T> struct _class<haxe::iterators::ArrayIterator<T>> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_haxe_iterators_ArrayIterator<haxe::iterators::ArrayIterator<T>>;
		constexpr static _class_data<4, 0> data {"ArrayIterator", { "array", "current", "hasNext", "next" }, {}, true};
	};
}
