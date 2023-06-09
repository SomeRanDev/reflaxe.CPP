#pragma once

#include <string>
#include "_HaxeUtils.h"

class StringBuf {
public:
	std::string b;

	StringBuf();

	HX_COMPARISON_OPERATORS(StringBuf)
};

