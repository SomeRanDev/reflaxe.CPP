#pragma once

#include "_AnonUtils.h"
#include "_HaxeUtils.h"
#include "_TypeUtils.h"
#include "haxe_Exception.h"
#include <dynamic/Dynamic.h>
#include <iostream>
#include <optional>
#include <string>

namespace _Main {

class Main_Fields_ {
public:
	static void main();
};

}


class Test {
public:
	int a;

	Test();
	
	void test();
	
	std::string toString();
	
	HX_COMPARISON_OPERATORS(Test)
};



template<typename T>
class HasParam {
public:
	T t;

	HasParam(T t):
		_order_id(generate_order_id())
	{
		this->t = t;
	}
	
	void test() {
		std::cout << std::string("test/unit_testing/tests/Dynamic/Main.hx:13: Hello!") << std::endl;
	}
	
	T getT() {
		return this->t;
	}
	
	HX_COMPARISON_OPERATORS(HasParam<T>)
};



#include "dynamic/Dynamic_Main.h"
#include "dynamic/Dynamic_Main.h"
#include "dynamic/Dynamic_Main.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<_Main::Main_Fields_> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic__Main_Main_Fields_;
		constexpr static _class_data<0, 1> data {"Main_Fields_", {}, { "main" }, true};
	};
	template<> struct _class<Test> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_Test;
		constexpr static _class_data<3, 0> data {"Test", { "a", "test", "toString" }, {}, true};
	};
	template<typename T> struct _class<HasParam<T>> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_HasParam<HasParam<T>>;
		constexpr static _class_data<3, 0> data {"HasParam", { "t", "test", "getT" }, {}, true};
	};
}
