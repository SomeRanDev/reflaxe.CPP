#pragma once

#include "_HaxeUtils.h"
#include "Other.h"
#include <memory>
#include <optional>

namespace _Main {

class Main_Fields_ {
public:
	static void main();
};

}


class Main {
public:
	Other other;

	Main();

	HX_COMPARISON_OPERATORS(Main)
};

