#include "Main.h"

#include "_AnonStructs.h"
#include "haxe_Exception.h"
#include "HxArray.h"
#include "HxString.h"
#include "Std.h"
#include <deque>
#include <iostream>
#include <memory>
#include <string>
using namespace std::string_literals;

int _Main::Main_Fields_::returnCode = 0;

void _Main::Main_Fields_::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Dynamic/Main.hx"s, 20, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		_Main::Main_Fields_::returnCode = 1;
	};
}

void _Main::Main_Fields_::main() {
	haxe::Dynamic d = std::make_shared<Test>();
	
	d.getProp("test")();
	_Main::Main_Fields_::assert(Std::string(d) == "this is toString"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 30, "main"s));
	_Main::Main_Fields_::assert(d.getProp("a") == 0, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 33, "main"s));
	d.setProp("a", 123);
	_Main::Main_Fields_::assert(d.getProp("a") == 123, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 35, "main"s));
	
	haxe::Dynamic d2 = std::make_shared<HasParam<int>>(333);
	
	_Main::Main_Fields_::assert(Std::string(d2) == "Dynamic"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 39, "main"s));
	_Main::Main_Fields_::assert(d2.getProp("getT")() == 333, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 40, "main"s));
	
	try {
		d2.getProp("bla")();
	} catch(haxe::Exception& e) {
		_Main::Main_Fields_::assert(e.get_message() == "Property does not exist"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 48, "main"s));
	};
	
	haxe::Dynamic arr = std::make_shared<std::deque<haxe::Dynamic>>(std::deque<haxe::Dynamic>{ 1, 2, 3 });
	
	arr.getProp("push")("Test"s);
	arr.getProp("push")(std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2 }));
	_Main::Main_Fields_::assert(arr.getProp("length") == 5, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 55, "main"s));
	_Main::Main_Fields_::assert(Std::string(arr) == "[1, 2, 3, Test, [1, 2]]"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 56, "main"s));
	_Main::Main_Fields_::assert(arr[2] == 3, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 57, "main"s));
	_Main::Main_Fields_::assert((arr[4].setProp("[]", 1)(333)) == 333, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 58, "main"s));
	_Main::Main_Fields_::assert(arr[4][0] == 1, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 59, "main"s));
	_Main::Main_Fields_::assert(arr[4] == (*std::make_shared<std::deque<int>>(std::deque<int>{ 1, 333 })), haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 60, "main"s));
	_Main::Main_Fields_::assert(Std::string(arr[4]) == "[1, 333]"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 61, "main"s));
	
	haxe::Dynamic str = "Hello!"s;
	
	_Main::Main_Fields_::assert(str == "Hello!"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 65, "main"s));
	_Main::Main_Fields_::assert(Std::string(str) + " Goodbye!"s == "Hello! Goodbye!"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 66, "main"s));
	str = Std::string(str) + " Goodbye!"s;
	_Main::Main_Fields_::assert(str == "Hello! Goodbye!"s, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 68, "main"s));
	
	haxe::Dynamic num = 10;
	
	_Main::Main_Fields_::assert(num + 10 == 20, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 72, "main"s));
	_Main::Main_Fields_::assert(num - 10 == 0, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 73, "main"s));
	_Main::Main_Fields_::assert(num * 5 == 50, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 74, "main"s));
	_Main::Main_Fields_::assert(num / 5 == 2, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 75, "main"s));
	_Main::Main_Fields_::assert(10 + num == 20, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 77, "main"s));
	_Main::Main_Fields_::assert(10 - num == 0, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 78, "main"s));
	_Main::Main_Fields_::assert(5 * num == 50, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 79, "main"s));
	_Main::Main_Fields_::assert(20 / num == 2, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 80, "main"s));
	num += 0;
	_Main::Main_Fields_::assert(num == 10, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 83, "main"s));
	num -= 2;
	_Main::Main_Fields_::assert(num == 8, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 86, "main"s));
	num *= 2;
	_Main::Main_Fields_::assert(num == 16, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 89, "main"s));
	num /= 2;
	_Main::Main_Fields_::assert(num == 8, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Dynamic/Main.hx"s, 92, "main"s));
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
