#pragma once

#include "_HaxeUtils.h"
#include <memory>
#include <optional>
#include <string>

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
	virtual void overridden(std::string a);
	void dummy(std::optional<int> optional = std::nullopt);

	HX_COMPARISON_OPERATORS(Base)
};



class Child: public Base {
public:
	Child();
	void overridden(std::string a) override;

	HX_COMPARISON_OPERATORS(Child)
};

