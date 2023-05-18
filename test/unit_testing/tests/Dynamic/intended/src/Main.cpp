#include "Main.h"

#include "_AnonStructs.h"
#include "cxx_DynamicToString.h"
#include "haxe_Exception.h"
#include "haxe_Log.h"
#include "haxe_NativeStackTrace.h"
#include "Std.h"
#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	HCXX_STACK_METHOD("test/unit_testing/tests/Dynamic/Main.hx"s, 17, 1, "_Main.Main_Fields_"s, "main"s);
	
	HCXX_LINE(18);
	haxe::Dynamic d = std::make_shared<Test>();
	
	HCXX_LINE(19);
	d.getProp("test")();
	HCXX_LINE(21);
	haxe::Log::trace(d, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 21, "main"s));
	HCXX_LINE(23);
	haxe::Log::trace(d.getProp("a"), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 23, "main"s));
	HCXX_LINE(24);
	d.setProp("a", 123);
	HCXX_LINE(25);
	haxe::Log::trace(d.getProp("a"), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 25, "main"s));
	
	HCXX_LINE(27);
	haxe::Dynamic d2 = std::make_shared<HasParam<int>>(333);
	
	HCXX_LINE(28);
	haxe::Log::trace(d2, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 28, "main"s));
	HCXX_LINE(29);
	haxe::Log::trace(d2.getProp("getT")(), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 29, "main"s));
	
	HCXX_LINE(31);
	try {
		HCXX_LINE(32);
		d2.getProp("bla")();
	} catch(haxe::Exception& e) {
		HCXX_LINE(34);
		haxe::DynamicToString v = e.details();
		
		HCXX_LINE(34);
		HCXX_LINE(34);
		std::cout << Std::string(v) << std::endl;
	};
}
Test::Test():
	_order_id(generate_order_id())
{
	HCXX_STACK_METHOD("test/unit_testing/tests/Dynamic/Main.hx"s, 5, 2, "Test"s, "Test"s);
	
	HCXX_LINE(4);
	this->a = 0;
}

void Test::test() {
	HCXX_STACK_METHOD("test/unit_testing/tests/Dynamic/Main.hx"s, 6, 2, "Test"s, "test"s);
	
	HCXX_LINE(6);
	std::cout << "test/unit_testing/tests/Dynamic/Main.hx:6: Hello!"s << std::endl;
}

std::string Test::toString() {
	HCXX_STACK_METHOD("test/unit_testing/tests/Dynamic/Main.hx"s, 7, 2, "Test"s, "toString"s);
	
	HCXX_LINE(7);
	return "this is toString"s;
}
