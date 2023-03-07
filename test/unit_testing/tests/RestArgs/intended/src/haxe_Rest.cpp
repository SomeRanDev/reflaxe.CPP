#include "haxe_Rest.h"

std::shared_ptr<haxe::_Rest::NativeRest<T>> haxe::_Rest::Rest_Impl_::append(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item) {
	std::deque<T> tempArray;
	
	{
		std::deque<T> result = (*this1);
		tempArray = result;
	};
	
	std::deque<T> result = tempArray;
	
	result.push_back(item);
	
	std::shared_ptr<haxe::_Rest::NativeRest<T>> this2 = std::make_shared<std::deque<T>>(result);
	std::shared_ptr<haxe::_Rest::NativeRest<T>> tempResult = this2;
	
	return tempResult;
}

std::shared_ptr<haxe::_Rest::NativeRest<T>> haxe::_Rest::Rest_Impl_::prepend(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item) {
	std::deque<T> tempArray;
	
	{
		std::deque<T> result = (*this1);
		tempArray = result;
	};
	
	std::deque<T> result = tempArray;
	
	result.push_front(item);
	
	std::shared_ptr<haxe::_Rest::NativeRest<T>> this2 = std::make_shared<std::deque<T>>(result);
	std::shared_ptr<haxe::_Rest::NativeRest<T>> tempResult = this2;
	
	return tempResult;
}
