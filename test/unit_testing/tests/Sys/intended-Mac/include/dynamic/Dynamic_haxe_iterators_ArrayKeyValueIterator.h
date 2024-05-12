#pragma once

#include "Dynamic.h"
namespace haxe {

template<typename T> class Dynamic_haxe_iterators_ArrayKeyValueIterator;

template<typename T>
class Dynamic_haxe_iterators_ArrayKeyValueIterator<haxe::iterators::ArrayKeyValueIterator<T>> {
public:
	static Dynamic getProp(Dynamic& d, std::string name) {
		// call const version if none found here
		return getProp(static_cast<Dynamic const&>(d), name);
	}

	static Dynamic getProp(Dynamic const&, std::string) {
		return Dynamic();
	}

	static Dynamic setProp(Dynamic&, std::string, Dynamic) {
		return Dynamic();
	}
};

}