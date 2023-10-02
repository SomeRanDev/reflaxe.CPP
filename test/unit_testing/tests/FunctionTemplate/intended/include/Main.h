#pragma once

#include <memory>
#include <optional>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Log.h"

namespace _Main {

class Main_Fields_ {
public:
	static void main();
	template<int T>
	static void hasGeneric() {
		haxe::Log::trace(T, haxe::shared_anon<haxe::PosInfos>(std::string("_Main.Main_Fields_"), std::string("test/unit_testing/tests/FunctionTemplate/Main.hx"), 8, std::string("hasGeneric")));
	}
};

}
