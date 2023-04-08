#pragma once

#include <string>

// Declare some C++ functions to use from Haxe

// C++ function that uses constexpr
constexpr int double_num(int num);

// C++ function that takes int and returns std::string (String)
std::string cpp_func(int input);

// C++ class
class MyClass {
public:
	MyClass(double value);

	void increment(double amount = 1.0);
	double getValue();

private:
	double value;
};
