#pragma once

#include <deque>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include "_HaxeUtils.h"
#include "haxe_Constraints.h"
#include "haxe_iterators_ArrayIterator.h"
#include "haxe_iterators_MapKeyValueIterator.h"
#include "Std.h"
#include "StdTypes.h"

namespace haxe::ds {

template<typename T>
class StringMap: public haxe::IMap<std::string, T>, public std::enable_shared_from_this<StringMap<T>> {
public:
	std::map<std::string, T> m;

	StringMap():
		_order_id(generate_order_id())
	{
		this->m = std::map<std::string, T>();
	}
	void set(std::string key, T value) {
		this->m.insert(std::pair<std::string, T>(key, value));
	}
	std::optional<T> get(std::string key) {
		std::optional<T> tempResult;

		if(this->exists(key)) {
			tempResult = this->m.at(key);
		} else {
			tempResult = std::nullopt;
		};

		return tempResult;
	}
	bool exists(std::string key) {
		return (int)(this->m.count(key)) > 0;
	}
	bool remove(std::string key) {
		return (int)(this->m.erase(key)) > 0;
	}
	std::shared_ptr<Iterator<std::string>> keys() {
		std::shared_ptr<std::deque<std::string>> keys = std::make_shared<std::deque<std::string>>();
		typename std::map<std::string, T>::iterator it = this->m.begin();
		typename std::map<std::string, T>::iterator end = this->m.end();

		for(; it != end; (it++)) {
			std::string x = it->first;

			keys->push_back(x);
		};

		return std::make_shared<Iterator<std::string>>(std::make_shared<haxe::iterators::ArrayIterator<std::string>>(keys));
	}
	std::shared_ptr<Iterator<T>> iterator() {
		std::shared_ptr<std::deque<T>> values = std::make_shared<std::deque<T>>();
		typename std::map<std::string, T>::iterator it = this->m.begin();
		typename std::map<std::string, T>::iterator end = this->m.end();

		for(; it != end; (it++)) {
			T x = it->second;

			values->push_back(x);
		};

		return std::make_shared<Iterator<T>>(std::make_shared<haxe::iterators::ArrayIterator<T>>(values));
	}
	std::shared_ptr<KeyValueIterator<std::string, T>> keyValueIterator() {
		return std::make_shared<KeyValueIterator<std::string, T>>(std::make_shared<haxe::iterators::MapKeyValueIterator<std::string, T>>(this->weak_from_this().expired() ? std::make_shared<haxe::ds::StringMap<T>>(*this) : this->shared_from_this()));
	}
	std::shared_ptr<haxe::ds::StringMap<T>> copyOG() {
		std::shared_ptr<haxe::ds::StringMap<T>> result = std::make_shared<haxe::ds::StringMap<T>>();
		std::shared_ptr<Iterator<std::string>> k = this->keys();

		while(k->hasNext()) {
			std::string k2 = k->next();

			result->set(k2, this->get(k2).value());
		};

		return result;
	}
	std::shared_ptr<haxe::IMap<std::string, T>> copy() {
		return std::static_pointer_cast<haxe::IMap<std::string, T>>(copyOG());
	}
	std::string toString() {
		std::string result = std::string("[");
		bool first = true;
		std::shared_ptr<haxe::IMap<std::string, T>> _g_map = this->weak_from_this().expired() ? std::make_shared<haxe::ds::StringMap<T>>(*this) : this->shared_from_this();
		std::shared_ptr<Iterator<std::string>> _g_keys = this->keys();

		while(_g_keys->hasNext()) {
			T _g_value;
			std::string _g_key;
			std::string key = _g_keys->next();

			_g_value = _g_map->get(key).value();
			_g_key = key;

			std::string key2 = _g_key;
			T value = _g_value;
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

	HX_COMPARISON_OPERATORS(StringMap<T>)
};

}
