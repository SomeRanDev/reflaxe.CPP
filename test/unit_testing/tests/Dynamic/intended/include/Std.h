#pragma once

#include <limits>
#include <memory>
#include <optional>
#include <string>
#include "_AnonUtils.h"
#include "cxx_DynamicToString.h"
#include "haxe_NativeStackTrace.h"

class Std {
public:
	static std::string string(haxe::DynamicToString s) {
		HCXX_STACK_METHOD(std::string("std/cxx/_std/Std.hx"), 42, 2, std::string("Std"), std::string("string"));
		
		HCXX_LINE(43);
		return s;
	}
	
	static std::optional<int> parseInt(std::string x) {
		HCXX_STACK_METHOD(std::string("std/cxx/_std/Std.hx"), 50, 2, std::string("Std"), std::string("parseInt"));
		
		HCXX_LINE(51);
		try { return std::stoi(x); } catch(...) {};
		
		HCXX_LINE(52);
		return std::nullopt;
	}
	
	static double parseFloat(std::string x) {
		HCXX_STACK_METHOD(std::string("std/cxx/_std/Std.hx"), 55, 2, std::string("Std"), std::string("parseFloat"));
		
		HCXX_LINE(56);
		try { return std::stof(x); } catch(...) {};
		
		HCXX_LINE(57);
		return std::numeric_limits<double>::quiet_NaN();
	}
};



#include "dynamic/Dynamic_Std.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<Std> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_Std;
		constexpr static _class_data<0, 3> data {"Std", {}, { "string", "parseInt", "parseFloat" }, true};
	};
}
