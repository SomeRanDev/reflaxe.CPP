#pragma once

#include <deque>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include "haxe_Constraints.h"
#include "haxe_iterators_ArrayIterator.h"
#include "haxe_iterators_MapKeyValueIterator.h"
#include "Std.h"
#include "StdTypes.h"

namespace haxe::ds {

template<typename T>
class IntMap: public haxe::IMap<int, T>, public std::enable_shared_from_this<IntMap<T>> {
public:
	std::map<int, T> m;

	IntMap(): _order_id(generate_order_id()) {
		this->m = std::map<int, T>();
	}
	
	void set(int key, T value) {
		this->m.insert(std::pair<int, T>(key, value));
	}
	
	std::optional<T> get(int key) {
		std::optional<T> tempResult;
		
		if(this->exists(key)) {
			tempResult = this->m.at(key);
		} else {
			tempResult = std::nullopt;
		};
		
		return tempResult;
	}
	
	bool exists(int key) {
		return this->m.count(key) > 0;
	}
	
	bool remove(int key) {
		return this->m.erase(key) > 0;
	}
	
	std::shared_ptr<Iterator<int>> keys() {
		std::shared_ptr<std::deque<int>> keys = std::make_shared<std::deque<int>>();
		typename std::map<int, T>::iterator it = this->m.begin();
		typename std::map<int, T>::iterator end = this->m.end();
		
		for(0; (*it) != (*end); (it++)) {
			keys->push_back(it->first);
		};
		
		return std::make_shared<Iterator<int>>(std::make_shared<haxe::iterators::ArrayIterator<int>>(keys));
	}
	
	std::shared_ptr<Iterator<T>> iterator() {
		std::shared_ptr<std::deque<T>> values = std::make_shared<std::deque<T>>();
		typename std::map<int, T>::iterator it = this->m.begin();
		typename std::map<int, T>::iterator end = this->m.end();
		
		for(0; (*it) != (*end); (it++)) {
			values->push_back(it->second);
		};
		
		return std::make_shared<Iterator<T>>(std::make_shared<haxe::iterators::ArrayIterator<T>>(values));
	}
	
	std::shared_ptr<KeyValueIterator<int, T>> keyValueIterator() {
		return std::make_shared<KeyValueIterator<int, T>>(std::make_shared<haxe::iterators::MapKeyValueIterator<int, T>>(this->shared_from_this()));
	}
	
	std::shared_ptr<haxe::ds::IntMap<T>> copy() {
		std::shared_ptr<haxe::ds::IntMap<T>> result = std::make_shared<haxe::ds::IntMap<T>>();
		std::shared_ptr<Iterator<int>> k = this->keys();
		
		while(k->hasNext()) {
			int k2 = k->next();
			result->set(k2, this->get(k2).value());
		};
		
		return result;
	}
	
	std::string toString() {
		std::string result = std::string("[");
		bool first = true;
		std::shared_ptr<haxe::IMap<int, T>> _g_map = this->shared_from_this();
		std::shared_ptr<Iterator<int>> _g_keys = this->keys();
		
		while(_g_keys->hasNext()) {
			T _g1_value;
			int _g1_key;
			int key = _g_keys->next();
			_g1_value = _g_map->get(key).value();
			_g1_key = key;
			int key2 = _g1_key;
			T value = _g1_value;
			std::string tempLeft;
			if(first) {
				tempLeft = std::string("");
			} else {
				tempLeft = std::string(", ");
			};
			result += tempLeft + (Std::string(key2) + std::string(" => ") + Std::string(value));
			if(first) {
				first = false;
			};
		};
		
		return result + std::string("]");
	}
	
	void clear() {
		this->m.clear();
	}
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const IntMap<T>& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const IntMap<T>& other) const {
		return _order_id < other._order_id;
	}
};

}
