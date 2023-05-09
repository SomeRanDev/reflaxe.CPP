#include "Main.h"

#include "_AnonStructs.h"
#include "dynamic/Dynamic.h"
#include "haxe_Log.h"
#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	haxe::Dynamic d = (std::make_shared<Test>());
	
	d.getProp("test")();
	haxe::Log::trace(d, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 14, "main"s));
	haxe::Log::trace(d.getProp("a"), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 16, "main"s));
	d.setProp("a", 123);
	haxe::Log::trace(d.getProp("a"), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 18, "main"s));
}
Test::Test(): _order_id(generate_order_id()) {
	this->a = 0;
}

void Test::test() {
	std::cout << "test/unit_testing/tests/Dynamic/Main.hx:6: Hello!"s << std::endl;
}

std::string Test::toString() {
	return "this is toString"s;
}
