#pragma once

#include <functional>
#include <map>
#include <memory>
#include <optional>
#include <string>
#include <utility>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "StdTypes.h"

namespace haxe {
namespace ds {

template<typename T>
class IntMap: public haxe::IMap<int, T> {
public:
	std::map<int, T> m;

	IntMap() {
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
		auto it = this->m.begin();
		auto end = this->m.end();
		
		return haxe::shared_anon<Iterator<int>>([&]() mutable {
			return it != end;
		}, [&]() mutable {
			int tempResult;
			if(it != end) {
				int result = it->first;
				(it++);
				return result;
			} else {
				tempResult = -1;
			};
			return tempResult;
		});
	}
	
	std::shared_ptr<Iterator<T>> iterator() {
		return haxe::shared_anon<Iterator<T><T>>([&]() mutable {
			return false;
		}, [&]() mutable {
			return static_cast<T>(std::nullopt);
		});
	}
	
	std::shared_ptr<KeyValueIterator<int, T>> keyValueIterator() {
		return haxe::shared_anon<haxe::AnonStruct0<T>>([&]() mutable {
			return std::nullopt;
		}, [&]() mutable {
			return false;
		});
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
		return std::string("");
	}
	
	void clear() {
		this->m.clear();
	}
};

}
}
