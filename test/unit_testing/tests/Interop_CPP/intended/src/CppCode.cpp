#include "CppCode.h"

// Functions

constexpr int double_num(int num) {
	return num * 2;
}

std::string cpp_func(int input) {
	return "The C++ function was given " + std::to_string(input) + "!";
}

// Class

MyClass::MyClass(double value):
	value(value)
{
}

void MyClass::increment(double amount) {
	value += amount;
}

double MyClass::getValue() {
	return value;
}
