#pragma once

#include <deque>
#include <memory>

namespace haxe {
namespace _Rest {

template<typename T>
using NativeRest = std::deque<T>;

}
}


namespace haxe {
namespace _Rest {

class Rest_Impl_ {
public:
	template<typename T>
	static std::shared_ptr<haxe::_Rest::NativeRest<T>> append(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item) {
		std::deque<T> result = std::deque(this1->begin(), this1->end());
		
		result.push_back(item);
		
		std::shared_ptr<haxe::_Rest::NativeRest<T>> this2 = std::make_shared<std::deque<T>>(result);
		std::shared_ptr<haxe::_Rest::NativeRest<T>> tempResult = this2;
		
		return tempResult;
	}
	
	template<typename T>
	static std::shared_ptr<haxe::_Rest::NativeRest<T>> prepend(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item) {
		std::deque<T> result = std::deque(this1->begin(), this1->end());
		
		result.push_front(item);
		
		std::shared_ptr<haxe::_Rest::NativeRest<T>> this2 = std::make_shared<std::deque<T>>(result);
		std::shared_ptr<haxe::_Rest::NativeRest<T>> tempResult = this2;
		
		return tempResult;
	}
};

}
}
