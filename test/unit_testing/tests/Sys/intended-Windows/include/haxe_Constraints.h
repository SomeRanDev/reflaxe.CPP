#pragma once

#include <memory>
#include <optional>
#include <string>
#include "StdTypes.h"

namespace haxe {

template<typename K, typename V>
class IMap {
public:
	virtual ~IMap() {}

	virtual std::optional<V> get(K k) = 0;
	
	virtual void set(K k, V v) = 0;
	
	virtual bool exists(K k) = 0;
	
	virtual bool remove(K k) = 0;
	
	virtual std::shared_ptr<Iterator<K>> keys() = 0;
	
	virtual std::shared_ptr<Iterator<V>> iterator() = 0;
	
	virtual std::shared_ptr<KeyValueIterator<K, V>> keyValueIterator() = 0;
	
	virtual std::shared_ptr<haxe::IMap<K, V>> copy() = 0;
	
	virtual std::string toString() = 0;
	
	virtual void clear() = 0;
};

}


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<typename K, typename V> struct _class<haxe::IMap<K, V>> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<10, 0> data {
		"IMap",
		{ "get", "set", "exists", "remove", "keys", "iterator", "keyValueIterator", "copy", "toString", "clear" },
		{},
		false
		};
	};
}
