#include "Main.h"

#include <functional>
#include <iostream>
#include <memory>
#include <type_traits>
#include "Std.h"

int Main::returnCode = 0;;

Main::Main() {
	this->testField = 123;
	Main::assert(this->testField == 123, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 9, "new"));
}

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(std::make_shared<haxe::PosInfos>("", "test/unit_testing/tests/BasicSyntax/Main.hx",15, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

int main() {
	Main::assert(true, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 23, "main"));
	Main::assert(!false, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 24, "main"));
	Main::assert(1 + 1 == 2, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 25, "main"));
	Main::assert(1 - 1 == 0, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 26, "main"));
	Main::assert(2 * 2 == 4, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 27, "main"));
	Main::assert(10 / 2 == 5, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 28, "main"));
	
	std::shared_ptr<Main> obj = std::make_shared<Main>();
	
	Main::assert(obj == obj, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 31, "main"));
	Main::assert(obj->testField == 123, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 32, "main"));
	
	std::string str = "World";
	
	str = "Hello, " + str;
	str += "!";
	Main::assert(str == "Hello, World!", std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 38, "main"));
	
	if(str != "Goodbye World!") {
		int num = 3;
		Main::assert(num > 1, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 42, "main"));
		Main::assert(num >= 3 && num >= 2, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 43, "main"));
		Main::assert(num == 3, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 44, "main"));
		Main::assert(num <= 3 && num <= 6, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 45, "main"));
		Main::assert(num < 4, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 46, "main"));
	} else {
		Main::assert(false, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 48, "main"));
	};
	
	int num = 3;
	
	Main::assert((num & 1) == 1, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 52, "main"));
	Main::assert((num & 4) == 0, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 53, "main"));
	Main::assert((num | 8) == 11, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 54, "main"));
	Main::assert((num | 3) == 3, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 55, "main"));
	Main::assert(1 + 1 == 1 + 1, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 57, "main"));
	
	std::string dict_hey = "Hey";
	std::shared_ptr<Main> dict_thing = obj;
	int dict_number = 3;
	
	Main::assert(dict_hey == "Hey", std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 65, "main"));
	Main::assert(dict_number == 3, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 66, "main"));
	
	std::any tempAny;
	
	{
		tempAny = 123;
	};
	
	std::any anyTest = tempAny;
	
	Main::assert(std::any_cast<int>(anyTest) == 123, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 69, "main"));
	Main::assert("<Any(" + Std::string(anyTest.type().name()) + ")>" == "<Any(int)>", std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 70, "main"));
	
	int arr_0 = 1;
	int arr_1 = 2;
	int arr_2 = 3;
	
	Main::assert(arr_1 == 2, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 73, "main"));
	Main::assert(3 == 3, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 74, "main"));
	
	bool _bool = true;
	
	Main::assert(_bool, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 77, "main"));
	
	int mutNum = 1000;
	
	mutNum++;
	mutNum++;
	Main::assert(mutNum++ == 1002, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 82, "main"));
	Main::assert(--mutNum == 1002, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 83, "main"));
	Main::assert(--mutNum == 1001, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 84, "main"));
	Main::assert(mutNum == 1001, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 85, "main"));
	
	std::function<void()> myFunc = [&]() mutable {
		mutNum++;
	};
	
	myFunc();
	myFunc();
	Main::assert(mutNum == 1003, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 92, "main"));
	
	int a = 2;
	int tempNumber = a * a;
	int blockVal = tempNumber;
	
	Main::assert(blockVal == 4, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 98, "main"));
	
	if(blockVal == 4) {
		Main::assert(true, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 101, "main"));
	} else {
		Main::assert(false, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 103, "main"));
	};
	
	int i = 0;
	
	while(true) {
		if(!(i++ < 1000)) {
			break;
		};
		if(i == 800) {
			Main::assert(i / 80 == 10, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 109, "main"));
		};
	};
	
	int j = 0;
	
	while(true) {
		int tempRight;
		Main::assert(true, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 115, "main"));
		tempRight = 6;
		if(!(j < tempRight)) {
			break;
		};
		Main::assert(true, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 118, "main"));
		j++;
	};
	
	int anotherNum = 3;
	int anotherNum2 = anotherNum;
	
	Main::assert(anotherNum == anotherNum2, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 124, "main"));
	anotherNum += 10;
	anotherNum2 = anotherNum;
	Main::assert(anotherNum == anotherNum2, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/BasicSyntax/Main.hx", 127, "main"));
	
	return 0;
}
