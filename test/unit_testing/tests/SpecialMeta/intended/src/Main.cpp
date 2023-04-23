#include "Main.h"

#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Log.h"

using namespace std::string_literals;

int Main::getValue() {
	return 123;
}

std::string Main::getValue2() {
	return "String"s;
}

void Main::main() {
	haxe::Log::trace(Main::getValue(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/SpecialMeta/Main.hx"s, 22, "main"s));
	haxe::Log::trace(Main::getValue2(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/SpecialMeta/Main.hx"s, 23, "main"s));
}
