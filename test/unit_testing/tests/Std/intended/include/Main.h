#pragma once

#include "haxe_PosInfos.h"
#include <memory>
#include <optional>
#include <string>

class BaseClass {
public:
	BaseClass();
};

class ChildClass: public BaseClass {
public:
	ChildClass();
};

class AnotherClass {
public:
	AnotherClass();
	
	std::string toString();
};

class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void assertFloat(double a, double b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void main();
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
	template<> struct _class<Main> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 4> data {"Main", {}, { "returnCode", "assert", "assertFloat", "main" }};
	};
}
