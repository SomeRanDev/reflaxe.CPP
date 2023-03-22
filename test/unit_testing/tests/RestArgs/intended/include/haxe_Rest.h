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
	static haxe::_Rest::NativeRest<T> append(haxe::_Rest::NativeRest<T> this1, T item) {
		std::deque<T> result = std::deque(this1.begin(), this1.end());
		
		result.push_back(item);
		
		haxe::_Rest::NativeRest<T> tempResult;
		
		{
			haxe::_Rest::NativeRest<T> this1 = result;
			tempResult = this1;
		};
		
		return tempResult;
	}
	
	template<typename T>
	static haxe::_Rest::NativeRest<T> prepend(haxe::_Rest::NativeRest<T> this1, T item) {
		std::deque<T> result = std::deque(this1.begin(), this1.end());
		
		result.push_front(item);
		
		haxe::_Rest::NativeRest<T> tempResult;
		
		{
			haxe::_Rest::NativeRest<T> this1 = result;
			tempResult = this1;
		};
		
		return tempResult;
	}
};

}
}
