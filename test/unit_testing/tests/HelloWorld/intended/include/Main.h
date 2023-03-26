#pragma once

namespace _Main {

class Main_Fields_ {
public:
	static void main();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const Main_Fields_& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const Main_Fields_& other) const {
		return _order_id < other._order_id;
	}
};

}
