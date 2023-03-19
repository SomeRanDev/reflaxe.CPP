#pragma once

#include "_AnonUtils.h"
#include "_TypeUtils.h"
#include <limits>
#include <optional>
#include <string>
#include <type_traits>
#include <utility>

template <typename T, typename = std::string>
struct HasToString : std::false_type { };

template <typename T>
struct HasToString <T, decltype(std::declval<T>().toString())> : std::true_type { };


class StdImpl {
public:
	template<typename _Value, typename _Type>
	static bool isOfType(_Value v, _Type t) {
		if constexpr(!haxe::_unwrap_class<_Type>::iscls) {
			return false;
		} else if constexpr(std::is_base_of<typename haxe::_unwrap_class<_Type>::inner, typename haxe::_unwrap_mm<_Value>::inner>::value) {
			return true;
		};
		
		return false;
	}
};

class Std {
public:
	template<typename T>
	static std::string string(T s) {
		if constexpr(haxe::optional_info<T>::isopt) {
			if(s.has_value()) {
				return Std::string(s.value());
			} else {
				return "null";
			}
		} else if constexpr(std::is_integral_v<T>) {
			return std::to_string(s);
		} else if constexpr(std::is_convertible<T, std::string>::value) {
			return std::string(s);
		} else if constexpr(HasToString<T>::value) {
			return s.toString();
		} else if constexpr(haxe::_unwrap_mm<T>::can_deref) {
			return Std::string(*s);
		};
		
		return "<unknown(size:" + std::to_string(sizeof(s)) + ")>";
	}
	
	static std::optional<int> parseInt(std::string x) {
		try { return std::stoi(x); } catch(...) {};
		
		return std::nullopt;
	}
	
	static double parseFloat(std::string x) {
		try { return std::stof(x); } catch(...) {};
		
		return std::numeric_limits<double>::quiet_NaN();
	}
};



// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<StdImpl> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 1> data {"StdImpl", {}, { "isOfType" }};
	};
	template<> struct _class<Std> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 3> data {"Std", {}, { "string", "parseInt", "parseFloat" }};
	};
}
