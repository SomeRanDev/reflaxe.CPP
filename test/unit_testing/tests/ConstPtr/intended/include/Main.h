#pragma once

#include "_HaxeUtils.h"

namespace _Main {

class Main_Fields_ {
public:
	static void main();
};

}


class Bla {
public:
	int a;

	Bla();
	
	void check() const;
	
	HX_COMPARISON_OPERATORS(Bla)
};

