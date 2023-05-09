#pragma once

#include "_HaxeUtils.h"
#include "_TypeUtils.h"
#include <dynamic/Dynamic.h>
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
}
