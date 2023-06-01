#pragma once

#include "_HaxeUtils.h"

class Test {
public:
	int a;

	Test();
	
	HX_COMPARISON_OPERATORS(Test)
};



namespace _Main {

class Main_Fields_ {
public:
	static Test t;

	static void main();
	
	static Test* getTest();
};

}
