#pragma once

#include "_AnonUtils.h"
#include "_TypeUtils.h"
#include "cxx_DynamicToString.h"
#include <limits>
#include <memory>
#include <optional>
#include <string>

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
	static std::string string(haxe::DynamicToString s) {
		return s;
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
