#pragma once

#include <deque>
#include <memory>

namespace haxe::_Rest {

template<typename T>
using NativeRest = std::deque<T>;

}

namespace haxe::_Rest {

class Rest_Impl_ {
public:
	template<typename T>
	static std::shared_ptr<haxe::_Rest::NativeRest<T>> append(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item) {
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
		
		std::shared_ptr<haxe::_Rest::NativeRest<T>> this2 = result;
		std::shared_ptr<haxe::_Rest::NativeRest<T>> tempResult = this2;
		
		return tempResult;
	}
	
	template<typename T>
	static std::shared_ptr<haxe::_Rest::NativeRest<T>> prepend(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item) {
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
		
		std::shared_ptr<haxe::_Rest::NativeRest<T>> this2 = result;
		std::shared_ptr<haxe::_Rest::NativeRest<T>> tempResult = this2;
		
		return tempResult;
	}
};

}
