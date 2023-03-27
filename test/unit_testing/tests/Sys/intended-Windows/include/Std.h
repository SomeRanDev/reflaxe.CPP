#pragma once

#include <limits>
#include <memory>
#include <optional>
#include <string>
#include "ucpp_DynamicToString.h"

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
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const Std& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const Std& other) const {
		return _order_id < other._order_id;
	}
};

