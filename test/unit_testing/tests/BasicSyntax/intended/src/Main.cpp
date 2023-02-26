#include "Main.h"

#include <functional>
#include <memory>
#include <type_traits>
#include "Std.h"

Main::Main() {
	this->testField = 123;
	Main::assert(this->testField == 123);
}

void Main::assert(bool b) {
	if(!b) {
		throw "Assert failed";
	};
}

void main() {
	Main::assert(true);
	Main::assert(!false);
	Main::assert(1 + 1 == 2);
	Main::assert(1 - 1 == 0);
	Main::assert(2 * 2 == 4);
	Main::assert(10 / 2 == 5);
	
	std::shared_ptr<Main> obj = std::make_shared<Main>();
	
	Main::assert(obj == obj);
	Main::assert(obj->testField == 123);
	
	std::string str = "World";
	
	str = "Hello, " + str;
	str += "!";
	Main::assert(str == "Hello, World!");
	
	if(str != "Goodbye World!") {
		int num = 3;
		Main::assert(num > 1);
		Main::assert(num >= 3 && num >= 2);
		Main::assert(num == 3);
		Main::assert(num <= 3 && num <= 6);
		Main::assert(num < 4);
	} else {
		Main::assert(false);
	};
	
	int num = 3;
	
	Main::assert((num & 1) == 1);
	Main::assert((num & 4) == 0);
	Main::assert((num | 8) == 11);
	Main::assert((num | 3) == 3);
	Main::assert(1 + 1 == 1 + 1);
	
	std::string dict_hey = "Hey";
	std::shared_ptr<Main> dict_thing = obj;
	int dict_number = 3;
	
	Main::assert(dict_hey == "Hey");
	Main::assert(dict_number == 3);
	
	std::any tempAny;
	
	{
		tempAny = 123;
	};
	
	std::any anyTest = tempAny;
	
	Main::assert(std::any_cast<int>(anyTest) == 123);
	Main::assert("<Any(" + Std::string(anyTest.type().name()) + ")>" == "<Any(int)>");
	
	int arr_0 = 1;
	int arr_1 = 2;
	int arr_2 = 3;
	
	Main::assert(arr_1 == 2);
	Main::assert(3 == 3);
	
	bool _bool = true;
	
	Main::assert(_bool);
	
	int mutNum = 1000;
	
	mutNum++;
	mutNum++;
	Main::assert(mutNum++ == 1002);
	Main::assert(--mutNum == 1002);
	Main::assert(--mutNum == 1001);
	Main::assert(mutNum == 1001);
	
	std::function<void()> myFunc = [=]() mutable {
		mutNum++;
	};
	
	myFunc();
	myFunc();
	Main::assert(mutNum == 1003);
	
	int a = 2;
	int tempNumber = a * a;
	int blockVal = tempNumber;
	
	Main::assert(blockVal == 4);
	
	if(blockVal == 4) {
		Main::assert(true);
	} else {
		Main::assert(false);
	};
	
	int i = 0;
	
	while(true) {
		if(!(i++ < 1000)) {
			break;
		};
		if(i == 800) {
			Main::assert(i / 80 == 10);
		};
	};
	
	int j = 0;
	
	while(true) {
		int tempRight;
		Main::assert(true);
		tempRight = 6;
		if(!(j < tempRight)) {
			break;
		};
		Main::assert(true);
		j++;
	};
	
	int anotherNum = 3;
	int anotherNum2 = anotherNum;
	
	Main::assert(anotherNum == anotherNum2);
	anotherNum += 10;
	anotherNum2 = anotherNum;
	Main::assert(anotherNum == anotherNum2);
}
