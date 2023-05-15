#pragma once

#include "_HaxeUtils.h"
#include "haxe_PosInfos.h"
#include <memory>
#include <optional>
#include <string>

class BaseClass {
public:
	BaseClass();
	
	HX_COMPARISON_OPERATORS(BaseClass)
};



class ChildClass: public BaseClass {
public:
	ChildClass();
	
	HX_COMPARISON_OPERATORS(ChildClass)
};



class AnotherClass {
public:
	AnotherClass();
	
	std::string toString();
	
	HX_COMPARISON_OPERATORS(AnotherClass)
};



class ClassWInt {
public:
	int number;

	ClassWInt();
	
	HX_COMPARISON_OPERATORS(ClassWInt)
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
	template<> struct _class<Main> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 4> data {"Main", {}, { "returnCode", "assert", "assertFloat", "main" }, false};
	};
	template<> struct _class<BaseClass> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 0> data {"BaseClass", {}, {}, false};
	};
	template<> struct _class<ChildClass> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 0> data {"ChildClass", {}, {}, false};
	};
	template<> struct _class<AnotherClass> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<1, 0> data {"AnotherClass", { "toString" }, {}, false};
	};
	template<> struct _class<ClassWInt> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<1, 0> data {"ClassWInt", { "number" }, {}, false};
	};
}
