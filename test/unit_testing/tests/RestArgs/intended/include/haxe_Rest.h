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
	static std::shared_ptr<haxe::_Rest::NativeRest<T>> append(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item);
	
	template<typename T>
	static std::shared_ptr<haxe::_Rest::NativeRest<T>> prepend(std::shared_ptr<haxe::_Rest::NativeRest<T>> this1, T item);
};

}
}
