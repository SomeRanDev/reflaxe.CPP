#pragma once

#include "_HaxeUtils.h"
#include "haxe_PosInfos.h"
#include <memory>
#include <optional>

class IValidating {
public:
	virtual ~IValidating() {}

	virtual bool validateComponent(bool nextFrame) = 0;
};



class Foo: public IValidating {
public:
	virtual ~Foo() {}

	Foo();
	virtual bool validateComponent(bool nextFrame = true);

	HX_COMPARISON_OPERATORS(Foo)
};



class Foo2: public Foo {
public:
	Foo2();
	bool validateComponent(bool nextFrame = false) override;

	HX_COMPARISON_OPERATORS(Foo2)
};

class Bar: public IValidating {
public:
	Bar();
	bool validateComponent(bool nextFrame = false);

	HX_COMPARISON_OPERATORS(Bar)
};



namespace _Main {

class Main_Fields_ {
public:
	static int returnCode;

	static void assert(bool v, bool v2, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	static void main();
};

}
