#pragma once

#include <string>
#include "_HaxeUtils.h"

class StringBuf {
public:
	std::string b;

	StringBuf();

	HX_COMPARISON_OPERATORS(StringBuf)
};



#include "dynamic/Dynamic_StringBuf.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<StringBuf> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_StringBuf;
		constexpr static _class_data<1, 0> data {"StringBuf", { "b" }, {}, true};
	};
}
