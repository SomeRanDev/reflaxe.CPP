#pragma once

#include <memory>
#include "_HaxeUtils.h"
#include "Other.h"

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

