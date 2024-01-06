#pragma once

#include "_HaxeUtils.h"
#include <memory>

namespace _Main {

class Main_Fields_ {
public:
	static void main();
};

}


class Base {
public:
	virtual ~Base() {}

	Base();
	virtual int getVal();
	int getVal2();

	HX_COMPARISON_OPERATORS(Base)
};



class Child: public Base {
public:
	Child();
	int getVal() override;

	HX_COMPARISON_OPERATORS(Child)
};

