#pragma once

#include <functional>
#include "_HaxeUtils.h"

class Main {
public:
	std::function<void()> fn;

	Main();
	static void main();

	HX_COMPARISON_OPERATORS(Main)
};

