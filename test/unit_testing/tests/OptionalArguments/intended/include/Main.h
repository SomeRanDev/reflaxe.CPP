#pragma once

#include "_HaxeUtils.h"
#include "haxe_PosInfos.h"
#include <memory>
#include <optional>
#include <string>

class Base {
public:
	virtual ~Base() {}

	Base();
	virtual void doThing(int num, std::string other);
	virtual void doThing2(std::optional<int> num, std::string other);

	HX_COMPARISON_OPERATORS(Base)
};



class Child: public Base {
public:
	Child();
	void doThing(int num, std::string other) override;
	void doThing2(std::optional<int> num, std::string other) override;

	HX_COMPARISON_OPERATORS(Child)
};



class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	static void testBackOpt(int first, std::string second = std::string("test"));
	static void testFrontOpt(int first, std::string second);
	static void testQuestionOpt(std::optional<int> maybeInt = std::nullopt, std::optional<std::string> maybeString = std::nullopt);
	static void testMixedOpt(int first, std::string second, bool third, int fourth);
	static void main();
};

