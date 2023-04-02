#pragma once

#include <memory>
#include <string>
#include "Map.h"

class SysImpl {
public:
	static std::shared_ptr<Map<std::string, std::string>> environment();
	
	static std::string systemName();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const SysImpl& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const SysImpl& other) const {
		return _order_id < other._order_id;
	}
};



// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<SysImpl> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 2> data {"SysImpl", {}, { "environment", "systemName" }};
	};
}
