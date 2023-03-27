#pragma once

#include <deque>
#include <memory>

namespace haxe::_Rest {

template<typename T>
using NativeRest = std::shared_ptr<std::deque<T>>;

}


namespace haxe::_Rest {

class Rest_Impl_ {
public:
	template<typename T>
	static haxe::_Rest::NativeRest<T> append(haxe::_Rest::NativeRest<T> this1, T item) {
		std::shared_ptr<std::deque<T>> tempArray;
		
		{
			std::shared_ptr<std::deque<T>> result = std::make_shared<std::deque<T>>(std::deque<T>{});
			{
				int _g = 0;
				std::shared_ptr<std::deque<T>> _g1 = this1;
				while(_g < _g1->size()) {
					T obj = (*_g1)[_g];
					++_g;
					result->push_back(obj);
				};
			};
			tempArray = result;
		};
		
		std::shared_ptr<std::deque<T>> result = tempArray;
		
		result->push_back(item);
		
		haxe::_Rest::NativeRest<T> this2 = result;
		haxe::_Rest::NativeRest<T> tempResult = this2;
		
		return tempResult;
	}
	
	template<typename T>
	static haxe::_Rest::NativeRest<T> prepend(haxe::_Rest::NativeRest<T> this1, T item) {
		std::shared_ptr<std::deque<T>> tempArray;
		
		{
			std::shared_ptr<std::deque<T>> result = std::make_shared<std::deque<T>>(std::deque<T>{});
			{
				int _g = 0;
				std::shared_ptr<std::deque<T>> _g1 = this1;
				while(_g < _g1->size()) {
					T obj = (*_g1)[_g];
					++_g;
					result->push_back(obj);
				};
			};
			tempArray = result;
		};
		
		std::shared_ptr<std::deque<T>> result = tempArray;
		
		result->push_front(item);
		
		haxe::_Rest::NativeRest<T> this2 = result;
		haxe::_Rest::NativeRest<T> tempResult = this2;
		
		return tempResult;
	}
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const Rest_Impl_& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const Rest_Impl_& other) const {
		return _order_id < other._order_id;
	}
};

}
