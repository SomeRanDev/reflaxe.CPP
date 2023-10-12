#pragma once

#include "_HaxeUtils.h"

namespace foo {

class Baz {
public:
	Baz();

	HX_COMPARISON_OPERATORS(Baz)
};

}
