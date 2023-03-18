#include "Main.h"

#include <any>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "EReg.h"
#include "haxe_Log.h"
#include "Std.h"

int Main::returnCode = 0;

Main::Main() {
	this->testField = 123;
	Main::assert(this->testField == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 9, "new"));
}

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/BasicSyntax/Main.hx", 15, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::assertStringEq(std::string first, std::string second, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(first != second) {
		std::string msg = "Assert failed, \"" + first + "\" does not equal \"" + second + "\".";
		haxe::Log::trace(msg, infos);
		Main::returnCode = 1;
	};
}

void Main::main() {
	Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 30, "main"));
	Main::assert(!false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 31, "main"));
	Main::assert(1 + 1 == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 32, "main"));
	Main::assert(1 - 1 == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 33, "main"));
	Main::assert(2 * 2 == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 34, "main"));
	Main::assert(10 / 2 == 5, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 35, "main"));
	
	std::shared_ptr<Main> obj = std::make_shared<Main>();
	
	Main::assert(obj == obj, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 39, "main"));
	Main::assert(obj->testField == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 40, "main"));
	
	std::string str = "World";
	
	str = "Hello, " + str;
	str += "!";
	Main::assertStringEq(str, "Hello, World!", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 47, "main"));
	
	if(str != "Goodbye World!") {
		int num = 3;
		Main::assert(num > 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 52, "main"));
		Main::assert(num >= 3 && num >= 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 53, "main"));
		Main::assert(num == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 54, "main"));
		Main::assert(num <= 3 && num <= 6, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 55, "main"));
		Main::assert(num < 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 56, "main"));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 58, "main"));
	};
	
	int num = 3;
	
	Main::assert((num & 1) == 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 63, "main"));
	Main::assert((num & 4) == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 64, "main"));
	Main::assert((num | 8) == 11, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 65, "main"));
	Main::assert((num | 3) == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 66, "main"));
	Main::assert(1 + 1 == 1 + 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 68, "main"));
	
	std::string dict_hey = "Hey";
	std::shared_ptr<Main> dict_thing = obj;
	int dict_number = 3;
	
	Main::assertStringEq(dict_hey, "Hey", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 77, "main"));
	Main::assert(dict_number == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 78, "main"));
	
	std::any anyTest = 123;
	
	Main::assert(std::any_cast<int>(anyTest) == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 82, "main"));
	Main::assert(EReg("Any\\(.+\\)", "").match("<Any(" + Std::string(anyTest.type().name()) + ")>"), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 86, "main"));
	
	int arr_0 = 1;
	int arr_1 = 2;
	int arr_2 = 3;
	
	Main::assert(arr_1 == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 90, "main"));
	Main::assert(3 == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 91, "main"));
	
	bool _bool = true;
	
	Main::assert(_bool, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 95, "main"));
	
	int mutNum = 1000;
	
	mutNum++;
	mutNum++;
	Main::assert(mutNum++ == 1002, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 101, "main"));
	Main::assert(--mutNum == 1002, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 102, "main"));
	Main::assert(--mutNum == 1001, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 103, "main"));
	Main::assert(mutNum == 1001, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 104, "main"));
	
	std::function<void()> myFunc = [&]() mutable {
		mutNum++;
	};
	
	myFunc();
	myFunc();
	Main::assert(mutNum == 1003, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 112, "main"));
	
	int a = 2;
	int tempNumber = a * a;
	int blockVal = tempNumber;
	
	Main::assert(blockVal == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 119, "main"));
	
	if(blockVal == 4) {
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 123, "main"));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 125, "main"));
	};
	
	int i = 0;
	
	while(true) {
		if(!(i++ < 1000)) {
			break;
		};
		if(i == 800) {
			Main::assert(i / 80 == 10, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 132, "main"));
		};
	};
	
	int j = 0;
	
	while(true) {
		int tempRight;
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 138, "main"));
		tempRight = 6;
		if(!(j < tempRight)) {
			break;
		};
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 141, "main"));
		j++;
	};
	
	int anotherNum = 3;
	int anotherNum2 = anotherNum;
	
	Main::assert(anotherNum == anotherNum2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 148, "main"));
	anotherNum += 10;
	anotherNum2 = anotherNum;
	Main::assert(anotherNum == anotherNum2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 151, "main"));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
