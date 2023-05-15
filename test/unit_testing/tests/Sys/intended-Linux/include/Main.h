#pragma once

#include <memory>
#include <optional>
#include "_HaxeUtils.h"
#include "haxe_PosInfos.h"

class Main {
public:
	int a;
	
	static int returnCode;

	Main();
	
	static void assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos = std::nullopt);
	
	static void main();
	
	HX_COMPARISON_OPERATORS(Main)
};



#include "dynamic/Dynamic_Main.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<Main> {
		DEFINE_CLASS_TOSTRING
	using Dyn = haxe::Dynamic_Main;
		constexpr static _class_data<1, 3> data {"Main", { "a" }, { "returnCode", "assert", "main" }, true};
	};
}
