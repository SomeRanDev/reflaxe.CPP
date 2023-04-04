#pragma once

#include "haxe_PosInfos.h"
#include <memory>
#include <optional>
#include <string>

class BaseClass {
public:
	BaseClass();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const BaseClass& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const BaseClass& other) const {
		return _order_id < other._order_id;
	}
};



class ChildClass: public BaseClass {
public:
	ChildClass();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const ChildClass& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const ChildClass& other) const {
		return _order_id < other._order_id;
	}
};



class AnotherClass {
public:
	AnotherClass();
	
	std::string toString();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const AnotherClass& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const AnotherClass& other) const {
		return _order_id < other._order_id;
	}
};



class ClassWInt {
public:
	int number;

	ClassWInt();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const ClassWInt& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const ClassWInt& other) const {
		return _order_id < other._order_id;
	}
};



class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void assertFloat(double a, double b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void main();
	
	// ----------
	// Auto-generated additions from Haxe
	
	// Generate unique id for each instance
	unsigned long _order_id = 0;
	static unsigned long generate_order_id() { static unsigned long i = 0; return i++; }
	
	// Automatic comparison operators
	bool operator==(const Main& other) const {
		return _order_id == other._order_id;
	}
	
	bool operator<(const Main& other) const {
		return _order_id < other._order_id;
	}
};



// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<BaseClass> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 0> data {"BaseClass", {}, {}};
	};
	template<> struct _class<ChildClass> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 0> data {"ChildClass", {}, {}};
	};
	template<> struct _class<AnotherClass> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<1, 0> data {"AnotherClass", { "toString" }, {}};
	};
	template<> struct _class<ClassWInt> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<1, 0> data {"ClassWInt", { "number" }, {}};
	};
	template<> struct _class<Main> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 4> data {"Main", {}, { "returnCode", "assert", "assertFloat", "main" }};
	};
}
