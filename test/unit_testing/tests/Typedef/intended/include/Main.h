#pragma once

#include "_HaxeUtils.h"
#include "haxe_PosInfos.h"
#include <memory>
#include <optional>

class ValueClass {
public:
	int val;

	ValueClass();
	
	HX_COMPARISON_OPERATORS(ValueClass)
};



class NormalClass {
public:
	NormalClass();
	
	HX_COMPARISON_OPERATORS(NormalClass)
};



using MyInt = int;


using MyIntInt = MyInt;


namespace _Main {

class Main_Fields_ {
public:
	static int exitCode;

	static void assert(bool cond, std::optional<std::shared_ptr<haxe::PosInfos>> pos = std::nullopt);
	
	static void main();
};

}
using ValueClassPtr = ValueClass;


using ValueClassPtr2 = ValueClass;


using ValueClassPtr2Value = ValueClass;


using ValueClassPtr2ValueSharedPtr = ValueClass;
