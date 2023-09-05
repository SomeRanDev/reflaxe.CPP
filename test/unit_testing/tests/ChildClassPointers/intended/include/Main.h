#pragma once

#include "_HaxeUtils.h"
#include <memory>

namespace _Main {

class Main_Fields_ {
public:
	static int returnCode;

	static void assert(bool v);
	static void main();
};

}
class A {
public:
	int val;
};



class B: public A {
public:
	B();

	HX_COMPARISON_OPERATORS(B)
};



class C {
public:
	int val;

	C();

	HX_COMPARISON_OPERATORS(C)
};

