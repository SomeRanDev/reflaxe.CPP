#include "Main.h"

#include <iostream>
#include <memory>
#include "haxe_Rest.h"
#include "HxArray.h"

int Main::returnCode = 0;;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(std::make_shared<haxe::PosInfos>("", "test/unit_testing/tests/RestArgs/Main.hx",10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::oneTwoThree(std::shared_ptr<haxe::_Rest::NativeRest<int>> numbers) {
	std::deque<int> tempLeft;
	
	{
		std::deque<int> result = (*numbers);
		tempLeft = result;
	};
	
	Main::assert(tempLeft == std::deque<int>{1, 2, 3}, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 18, "oneTwoThree"));
	Main::assert(HxArray::toString<int>((*numbers)) == "[1, 2, 3]", std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 19, "oneTwoThree"));
	
	std::deque<int> tempArray;
	
	{
		std::deque<int> result = (*numbers);
		tempArray = result;
	};
	
	std::deque<int> arr = tempArray;
	
	arr.push_back(123);
	Main::assert(HxArray::toString<int>(arr) == "[1, 2, 3, 123]", std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 24, "oneTwoThree"));
	
	int i = 1;
	int _g = 0;
	
	while(_g < arr.size()) {
		int a = arr[_g];
		++_g;
		Main::assert(a == i, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 29, "oneTwoThree"));
		i++;
	};
	
	haxe::_Rest::Rest_Impl_::append(numbers, 4);
	
	std::deque<int> tempLeft1;
	
	{
		std::deque<int> result = (*numbers);
		tempLeft1 = result;
	};
	
	Main::assert(tempLeft1 == std::deque<int>{1, 2, 3, 4}, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 35, "oneTwoThree"));
	haxe::_Rest::Rest_Impl_::prepend(numbers, 0);
	
	std::deque<int> tempLeft2;
	
	{
		std::deque<int> result = (*numbers);
		tempLeft2 = result;
	};
	
	Main::assert(tempLeft2 == std::deque<int>{0, 1, 2, 3, 4}, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 39, "oneTwoThree"));
}

int main() {
	std::shared_ptr<haxe::_Rest::NativeRest<int>> tempRest;
	
	{
		std::shared_ptr<haxe::_Rest::NativeRest<int>> this1;
		this1 = std::make_shared<std::deque<int>>(std::deque<int>{1, 2, 3});
		tempRest = this1;
	};
	
	Main::oneTwoThree(tempRest);
	
	return Main::returnCode;
}
