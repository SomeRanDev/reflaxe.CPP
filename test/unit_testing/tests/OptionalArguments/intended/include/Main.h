#pragma once

#include "_HaxeUtils.h"
#include "haxe_PosInfos.h"
#include <memory>
#include <optional>
#include <string>

class Base {
public:
	Base();
	
	virtual void doThing(int num, std::string other);
	
	virtual void doThing2(std::optional<int> num, std::string other);
	
	HX_COMPARISON_OPERATORS(Base)
};



class Child: public Base {
public:
	Child();
	
	void doThing(int num, std::string other);
	
	void doThing2(std::optional<int> num, std::string other);
	
	HX_COMPARISON_OPERATORS(Child)
};



class Main {
public:
	static int returnCode;

	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void testFrontOpt(int first, std::string second);
	
	static void main();
};

