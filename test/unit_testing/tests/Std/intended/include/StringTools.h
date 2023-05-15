#pragma once

#include <string>

class StringTools {
public:
	static bool startsWith(std::string s, std::string start);
};



// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<StringTools> {
		DEFINE_CLASS_TOSTRING
		constexpr static _class_data<0, 1> data {"StringTools", {}, { "startsWith" }, false};
	};
}
