#pragma once

#include <optional>

namespace _Main {

class Main_Fields_ {
public:
	static void main();
};

}


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<_Main::Main_Fields_> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 1> data {"Main_Fields_", {}, { "main" }, false};
	};
}
