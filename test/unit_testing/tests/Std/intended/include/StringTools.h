#pragma once

#include <string>

class StringTools {
public:
	static bool startsWith(std::string s, std::string start);
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const StringTools& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const StringTools& other) const {
		return _order_id < other._order_id;
	}
};



// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<StringTools> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 1> data {"StringTools", {}, { "startsWith" }};
	};
}
