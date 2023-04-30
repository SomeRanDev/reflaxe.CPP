#include "Main.h"

#include <any>
#include <cstdlib>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "EReg.h"
#include "haxe_Log.h"
#include "Std.h"

using namespace std::string_literals;

int Main::returnCode = 0;

Main::Main(): _order_id(generate_order_id()) {
	this->testField = 123;
	Main::assert(this->testField == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 9, "new"s));
}

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/BasicSyntax/Main.hx"s, 15, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::assertStringEq(std::string first, std::string second, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(first != second) {
		std::string msg = "Assert failed, \""s + first + "\" does not equal \""s + second + "\"."s;
		haxe::Log::trace(msg, infos);
		Main::returnCode = 1;
	};
}

void Main::main() {
	Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 30, "main"s));
	Main::assert(!false, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 31, "main"s));
	Main::assert(1 + 1 == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 32, "main"s));
	Main::assert(1 - 1 == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 33, "main"s));
	Main::assert(2 * 2 == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 34, "main"s));
	Main::assert(10 / 2 == 5, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 35, "main"s));
	
	std::shared_ptr<Main> obj = std::make_shared<Main>();
	
	Main::assert((*obj) == (*obj), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 39, "main"s));
	Main::assert(obj->testField == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 40, "main"s));
	
	std::string str = "World"s;
	
	str = "Hello, "s + str;
	str += "!"s;
	Main::assertStringEq(str, "Hello, World!"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 47, "main"s));
	
	if(str != "Goodbye World!"s) {
		int num = 3;
		Main::assert(num > 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 52, "main"s));
		Main::assert(num >= 3 && num >= 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 53, "main"s));
		Main::assert(num == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 54, "main"s));
		Main::assert(num <= 3 && num <= 6, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 55, "main"s));
		Main::assert(num < 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 56, "main"s));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 58, "main"s));
	};
	
	int num = 3;
	
	Main::assert((num & 1) == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 63, "main"s));
	Main::assert((num & 4) == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 64, "main"s));
	Main::assert((num | 8) == 11, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 65, "main"s));
	Main::assert((num | 3) == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 66, "main"s));
	Main::assert(1 + 1 == 1 + 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 68, "main"s));
	
	std::string dict_hey = "Hey"s;
	std::shared_ptr<Main> dict_thing = obj;
	int dict_number = 3;
	
	Main::assertStringEq(dict_hey, "Hey"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 77, "main"s));
	Main::assert(dict_number == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 78, "main"s));
	
	std::any anyTest = 123;
	
	Main::assert(std::any_cast<int>(anyTest) == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 82, "main"s));
	
	std::string tempString = "<Any("s + Std::string(anyTest.type().name()) + ")>"s;
	
	Main::assert(EReg("Any\\(.+\\)"s, ""s).match(tempString), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 86, "main"s));
	
	int arr_0 = 1;
	int arr_1 = 2;
	int arr_2 = 3;
	
	Main::assert(arr_1 == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 90, "main"s));
	Main::assert(3 == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 91, "main"s));
	
	bool _bool = true;
	
	Main::assert(_bool, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 95, "main"s));
	
	int mutNum = 1000;
	
	mutNum++;
	mutNum++;
	Main::assert(mutNum++ == 1002, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 101, "main"s));
	Main::assert(--mutNum == 1002, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 102, "main"s));
	Main::assert(--mutNum == 1001, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 103, "main"s));
	Main::assert(mutNum == 1001, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 104, "main"s));
	
	std::function<void()> myFunc = [&]() mutable {
		mutNum++;
	};
	
	myFunc();
	myFunc();
	Main::assert(mutNum == 1003, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 112, "main"s));
	
	int a = 2;
	int tempNumber = a * a;
	int blockVal = tempNumber;
	
	Main::assert(blockVal == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 119, "main"s));
	
	if(blockVal == 4) {
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 123, "main"s));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 125, "main"s));
	};
	
	int i = 0;
	
	while(true) {
		if(!(i++ < 1000)) {
			break;
		};
		if(i == 800) {
			Main::assert(i / 80 == 10, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 132, "main"s));
		};
	};
	
	int j = 0;
	
	while(true) {
		int tempRight;
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 138, "main"s));
		tempRight = 6;
		if(!(j < tempRight)) {
			break;
		};
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 141, "main"s));
		j++;
	};
	
	int anotherNum = 3;
	int anotherNum2 = anotherNum;
	
	Main::assert(anotherNum == anotherNum2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 148, "main"s));
	anotherNum += 10;
	anotherNum2 = anotherNum;
	Main::assert(anotherNum == anotherNum2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 151, "main"s));
	
	float float32 = 12.32;
	
	Main::assert(abs(float32 - 12.32) < 0.0001, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/BasicSyntax/Main.hx"s, 155, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
