#include "Main.h"

#include <any>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
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

int main() {
	Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 24, "main"));
	Main::assert(!false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 25, "main"));
	Main::assert(1 + 1 == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 26, "main"));
	Main::assert(1 - 1 == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 27, "main"));
	Main::assert(2 * 2 == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 28, "main"));
	Main::assert(10 / 2 == 5, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 29, "main"));
	
	std::shared_ptr<Main> obj = std::make_shared<Main>();
	
	Main::assert(obj == obj, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 33, "main"));
	Main::assert(obj->testField == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 34, "main"));
	
	std::string str = "World";
	
	str = "Hello, " + str;
	str += "!";
	Main::assert(str == "Hello, World!", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 41, "main"));
	
	if(str != "Goodbye World!") {
		int num = 3;
		Main::assert(num > 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 46, "main"));
		Main::assert(num >= 3 && num >= 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 47, "main"));
		Main::assert(num == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 48, "main"));
		Main::assert(num <= 3 && num <= 6, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 49, "main"));
		Main::assert(num < 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 50, "main"));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 52, "main"));
	};
	
	int num = 3;
	
	Main::assert((num & 1) == 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 57, "main"));
	Main::assert((num & 4) == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 58, "main"));
	Main::assert((num | 8) == 11, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 59, "main"));
	Main::assert((num | 3) == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 60, "main"));
	Main::assert(1 + 1 == 1 + 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 62, "main"));
	
	std::string dict_hey = "Hey";
	std::shared_ptr<Main> dict_thing = obj;
	int dict_number = 3;
	
	Main::assert(dict_hey == "Hey", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 71, "main"));
	Main::assert(dict_number == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 72, "main"));
	
	std::any anyTest = 123;
	
	Main::assert(std::any_cast<int>(anyTest) == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 76, "main"));
	Main::assert("<Any(" + Std::string(anyTest.type().name()) + ")>" == "<Any(int)>", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 77, "main"));
	
	int arr_0 = 1;
	int arr_1 = 2;
	int arr_2 = 3;
	
	Main::assert(arr_1 == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 81, "main"));
	Main::assert(3 == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 82, "main"));
	
	bool _bool = true;
	
	Main::assert(_bool, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 86, "main"));
	
	int mutNum = 1000;
	
	mutNum++;
	mutNum++;
	Main::assert(mutNum++ == 1002, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 92, "main"));
	Main::assert(--mutNum == 1002, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 93, "main"));
	Main::assert(--mutNum == 1001, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 94, "main"));
	Main::assert(mutNum == 1001, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 95, "main"));
	
	std::function<void()> myFunc = [&]() mutable {
		mutNum++;
	};
	
	myFunc();
	myFunc();
	Main::assert(mutNum == 1003, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 103, "main"));
	
	int a = 2;
	int tempNumber = a * a;
	int blockVal = tempNumber;
	
	Main::assert(blockVal == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 110, "main"));
	
	if(blockVal == 4) {
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 114, "main"));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 116, "main"));
	};
	
	int i = 0;
	
	while(true) {
		if(!(i++ < 1000)) {
			break;
		};
		if(i == 800) {
			Main::assert(i / 80 == 10, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 123, "main"));
		};
	};
	
	int j = 0;
	
	while(true) {
		int tempRight;
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 129, "main"));
		tempRight = 6;
		if(!(j < tempRight)) {
			break;
		};
		Main::assert(true, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 132, "main"));
		j++;
	};
	
	int anotherNum = 3;
	int anotherNum2 = anotherNum;
	
	Main::assert(anotherNum == anotherNum2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 139, "main"));
	anotherNum += 10;
	anotherNum2 = anotherNum;
	Main::assert(anotherNum == anotherNum2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 142, "main"));
	
	return Main::returnCode;
}
