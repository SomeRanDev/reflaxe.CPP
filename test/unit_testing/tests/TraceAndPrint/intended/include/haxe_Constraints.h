#pragma once

#include <memory>
#include <optional>
#include "StdTypes.h"

namespace haxe {

template<typename K, typename V>
class IMap {
public:
	virtual std::optional<V> get(K k) = 0;
	
	virtual std::shared_ptr<Iterator<K>> keys() = 0;
};

}
