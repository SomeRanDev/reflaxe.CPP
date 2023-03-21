#pragma once

#include <deque>
#include <functional>
#include <memory>
#include <optional>
#include <string>
#include "Std.h"

class HxArray {
public:
	template<typename T>
	static std::deque<T> concat(std::deque<T> a, std::deque<T> other) {
		std::deque<T> result = a;
		int _g = 0;
		
		while(_g < other.size()) {
			T o = other[_g];
			++_g;
			result.push_back(o);
		};
		
		return result;
	}
	
	template<typename T>
	static std::string join(std::deque<T> a, std::string sep) {
		std::string result = std::string("");
		int _g = 0;
		int _g1 = a.size();
		
		while(_g < _g1) {
			int i = _g++;
			if(i > 0) {
				result += sep;
			};
			result += Std::string(a[i]);
		};
		
		return result;
	}
	
	template<typename T>
	static std::deque<T> slice(std::deque<T> a, int pos, std::optional<int> end = std::nullopt) {
		if(pos < 0) {
			pos += a.size();
		};
		if(pos < 0 || pos > a.size()) {
			return std::deque<T>{};
		};
		if(!end.has_value() || end.value() > a.size()) {
			end = a.size();
		} else {
			if(end.value() < 0) {
				end.value() += a.size();
			};
			if(end.value() <= pos) {
				return std::deque<T>{};
			};
		};
		
		auto beginIt = a.begin();
		auto startIt = beginIt + pos;
		auto endIt = beginIt + end.value();
		
		return std::deque(startIt, endIt);
	}
	
	template<typename T>
	static std::deque<T> splice(std::deque<T>& a, int pos, int len) {
		if(pos < 0) {
			pos += a.size();
		};
		if(pos < 0 || pos > a.size()) {
			return std::deque<T>{};
		};
		if(len < 0) {
			return std::deque<T>{};
		};
		if(pos + len > a.size()) {
			len = a.size() - pos;
		};
		
		auto beginIt = a.begin();
		auto startIt = beginIt + pos;
		auto endIt = beginIt + pos + len;
		std::deque<T> result = std::deque(startIt, endIt);
		
		a.erase(startIt, endIt);
		
		return result;
	}
	
	template<typename T>
	static void insert(std::deque<T>& a, int pos, T x) {
		if(pos < 0) {
			auto it = a.end() + pos + 1;
			a.insert(it, x);
		} else {
			auto it = a.begin() + pos;
			a.insert(it, x);
		};
	}
	
	template<typename T>
	static int indexOf(std::deque<T> a, T x, int fromIndex = 0) {
		auto it = std::find(a.begin(), a.end(), x);
		int tempResult;
		
		if(it != a.end()) {
			tempResult = it - a.begin();
		} else {
			tempResult = -1;
		};
		
		return tempResult;
	}
	
	template<typename T, typename S>
	static std::deque<S> map(std::deque<T> a, std::function<S(T)> f) {
		std::deque<S> _g = std::deque<S>{};
		int _g1 = 0;
		
		while(_g1 < a.size()) {
			T v = a[_g1];
			++_g1;
			_g.push_back(f(v));
		};
		
		std::deque<S> tempResult = _g;
		
		return tempResult;
	}
	
	template<typename T>
	static std::deque<T> filter(std::deque<T> a, std::function<bool(T)> f) {
		std::deque<T> _g = std::deque<T>{};
		int _g1 = 0;
		
		while(_g1 < a.size()) {
			T v = a[_g1];
			++_g1;
			if(f(v)) {
				_g.push_back(v);
			};
		};
		
		std::deque<T> tempResult = _g;
		
		return tempResult;
	}
	
	template<typename T>
	static std::string toString(std::deque<T> a) {
		std::string result = std::string("[");
		int _g = 0;
		int _g1 = a.size();
		
		while(_g < _g1) {
			int i = _g++;
			std::string tempLeft;
			if(i != 0) {
				tempLeft = std::string(", ");
			} else {
				tempLeft = std::string("");
			};
			result += tempLeft + Std::string(a[i]);
		};
		
		return result + std::string("]");
	}
};

