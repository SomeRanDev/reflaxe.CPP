#pragma once

#include "_HaxeUtils.h"

namespace _Main {

class Main_Fields_ {
public:
	static void main();
};

}


class FooBuilder {
public:
	FooBuilder();
	FooBuilder* withBar();

	HX_COMPARISON_OPERATORS(FooBuilder)
};

