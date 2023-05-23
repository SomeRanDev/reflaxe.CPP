#include "Main.h"

#include "_AnonStructs.h"
#include "cxx_DynamicToString.h"
#include "haxe_Exception.h"
#include "haxe_Log.h"
#include "HxArray.h"
#include "HxString.h"
#include "Std.h"
#include <deque>
#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	haxe::Dynamic d = std::make_shared<Test>();
	
	d.getProp("test")();
	haxe::Log::trace(d, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 21, "main"s));
	haxe::Log::trace(d.getProp("a"), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 23, "main"s));
	d.setProp("a", 123);
	haxe::Log::trace(d.getProp("a"), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 25, "main"s));
	
	haxe::Dynamic d2 = std::make_shared<HasParam<int>>(333);
	
	haxe::Log::trace(d2, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 28, "main"s));
	haxe::Log::trace(d2.getProp("getT")(), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 29, "main"s));
	
	try {
	
	} catch(haxe::Exception& e) {
		haxe::DynamicToString v = e.details();
		
		std::cout << Std::string(v) << std::endl;
	};
	try {
		haxe::Dynamic arr = std::make_shared<std::deque<haxe::Dynamic>>(std::deque<haxe::Dynamic>{ 1, 2, 3 });
		
		arr.getProp("push")("Test"s);
		arr.getProp("push")(std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2 }));
		haxe::Log::trace(arr.getProp("length"), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 44, "main"s));
		haxe::Log::trace(arr, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 45, "main"s));
		haxe::Log::trace(arr[2], haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 46, "main"s));
		arr[4].setProp("[]", 1)(333);
		haxe::Log::trace(arr[4][1], haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 47, "main"s));
		haxe::Log::trace(arr[4][0], haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 48, "main"s));
		haxe::Log::trace(arr[4], haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 49, "main"s));
		haxe::Log::trace(arr[4] == (*std::make_shared<std::deque<int>>(std::deque<int>{ 1, 333 })), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 51, "main"s));
	} catch(haxe::Exception& e) {
		haxe::Log::trace(e.get_message(), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 53, "main"s));
	};
}
Test::Test():
	_order_id(generate_order_id())
{
	this->a = 0;
}

void Test::test() {
	std::cout << "test/unit_testing/tests/Dynamic/Main.hx:6: Hello!"s << std::endl;
}

std::string Test::toString() {
	return "this is toString"s;
}
