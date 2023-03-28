#pragma once

#include "haxe_PosInfos.h"
#include "ucpp_DynamicToString.h"
#include <deque>
#include <memory>
#include <optional>
#include <string>

class ValueClass {
public:
	int val;

	ValueClass();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const ValueClass& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const ValueClass& other) const {
		return _order_id < other._order_id;
	}
};

class NormalClass {
public:
	NormalClass();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const NormalClass& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const NormalClass& other) const {
		return _order_id < other._order_id;
	}
};



using MyInt = int;


namespace _Main {

class Main_Fields_ {
public:
	static int exitCode;

	static void assert(bool cond, std::optional<std::shared_ptr<haxe::PosInfos>> pos = std::nullopt);
	
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
using MyIntInt = MyInt;


using ValueClassDef = ValueClass;


using ValueClassPtr = ValueClass*;


using ValueClassPtr2 = ValueClass*;


using ValueClassPtr2Value = ValueClass;


using ValueClassPtr2ValueSharedPtr = std::shared_ptr<ValueClass>;
