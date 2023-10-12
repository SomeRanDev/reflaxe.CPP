#pragma once

class MyClass {
};



// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<MyClass> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 0> data {"MyClass", {}, {}, false};
	};
}
