#pragma once

#define HX_COMPARISON_OPERATORS(...)\
	unsigned long _order_id = 0;\
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }\
	bool operator==(const __VA_ARGS__& other) const { return _order_id == other._order_id; }\
	bool operator<(const __VA_ARGS__& other) const { return _order_id < other._order_id; }\
	operator bool() const { return true; }

