#pragma once

namespace haxe::iterators {

template<typename T>
class ArrayKeyValueIterator {
};

}


#include "dynamic/Dynamic_haxe_iterators_ArrayKeyValueIterator.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<typename T> struct _class<haxe::iterators::ArrayKeyValueIterator<T>> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_haxe_iterators_ArrayKeyValueIterator<haxe::iterators::ArrayKeyValueIterator<T>>;
		constexpr static _class_data<0, 0> data {"ArrayKeyValueIterator", {}, {}, true};
	};
}
