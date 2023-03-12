#include "Main.h"

#include <any>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Rest.h"
#include "HxArray.h"

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/RestArgs/Main.hx", 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::oneTwoThree(std::shared_ptr<haxe::_Rest::NativeRest<int>> numbers) {
	Main::assert(std::deque(numbers->begin(), numbers->end()) == std::deque<int>{ 1, 2, 3 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 18, "oneTwoThree"));
	Main::assert(HxArray::toString<int>((*numbers)) == "[1, 2, 3]", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 19, "oneTwoThree"));
	
	std::deque<int> arr = std::deque(numbers->begin(), numbers->end());
	
	arr.push_back(123);
	Main::assert(HxArray::toString<int>(arr) == "[1, 2, 3, 123]", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 24, "oneTwoThree"));
	
	int i = 1;
	int _g_current = 0;
	std::shared_ptr<haxe::_Rest::NativeRest<int>> _g_args = std::any_cast<std::shared_ptr<haxe::_Rest::NativeRest<int>>>(numbers);
	
	while(_g_current < _g_args->size()) {
		int tempNumber;
		std::shared_ptr<haxe::_Rest::NativeRest<int>> this1 = _g_args;
		int index = _g_current++;
		tempNumber = (*this1)[index];
		int a = tempNumber;
		Main::assert(a == i, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 29, "oneTwoThree"));
		i++;
	};
	
	std::deque<int> tempLeft;
	
	{
		std::shared_ptr<haxe::_Rest::NativeRest<int>> this1 = haxe::_Rest::Rest_Impl_::append(numbers, 4);
		tempLeft = std::deque(this1->begin(), this1->end());
	};
	
	Main::assert(tempLeft == std::deque<int>{ 1, 2, 3, 4 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 34, "oneTwoThree"));
	
	std::deque<int> tempLeft1;
	
	{
		std::shared_ptr<haxe::_Rest::NativeRest<int>> this1 = haxe::_Rest::Rest_Impl_::prepend(numbers, 0);
		tempLeft1 = std::deque(this1->begin(), this1->end());
	};
	
	Main::assert(tempLeft1 == std::deque<int>{ 0, 1, 2, 3 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 37, "oneTwoThree"));
}

void Main::testRest(std::shared_ptr<haxe::_Rest::NativeRest<std::string>> strings) {
	Main::assert(std::deque(strings->begin(), strings->end()) == std::deque<std::string>{
		"one",
		"two",
		"three"
	}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 42, "testRest"));
}

void Main::testRestAny(std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>>> anys) {
	Main::assert(std::any_cast<std::deque<int>>((*anys)[1]->data) == std::deque<int>{ 0, 500, 1000 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 47, "testRestAny"));
	Main::assert(std::any_cast<std::deque<int>>((*anys)[1]->data)[1] == 500, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 48, "testRestAny"));
	Main::assert(std::any_cast<std::deque<int>>((*anys)[1]->data)[2] == 1000, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 49, "testRestAny"));
}

void Main::testRestAny2(std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct1>>> anys) {
	Main::assert((*anys)[0]->data == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 54, "testRestAny2"));
	Main::assert(!(*anys)[1]->data.has_value(), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 55, "testRestAny2"));
	Main::assert((*anys)[2]->data == 369, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/RestArgs/Main.hx", 56, "testRestAny2"));
}

int main() {
	std::shared_ptr<haxe::_Rest::NativeRest<int>> tempRest;
	
	{
		std::shared_ptr<haxe::_Rest::NativeRest<int>> this1;
		this1 = std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2, 3 });
		tempRest = this1;
	};
	
	Main::oneTwoThree(tempRest);
	
	std::shared_ptr<haxe::_Rest::NativeRest<std::string>> tempRest1;
	
	{
		std::shared_ptr<haxe::_Rest::NativeRest<std::string>> this1;
		this1 = std::make_shared<std::deque<std::string>>(std::deque<std::string>{
			"one",
			"two",
			"three"
		});
		tempRest1 = this1;
	};
	
	Main::testRest(tempRest1);
	
	std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>>> tempRest2;
	
	{
		std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>>> this1;
		this1 = std::make_shared<std::deque<std::shared_ptr<haxe::AnonStruct0>>>(std::deque<std::shared_ptr<haxe::AnonStruct0>>{
			haxe::shared_anon<haxe::AnonStruct0>(static_cast<std::any>(std::nullopt)),
			haxe::shared_anon<haxe::AnonStruct0>(std::deque<int>{ 0, 500, 1000 })
		});
		tempRest2 = this1;
	};
	
	Main::testRestAny(tempRest2);
	
	std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct1>>> tempRest3;
	
	{
		std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct1>>> this1;
		this1 = std::make_shared<std::deque<std::shared_ptr<haxe::AnonStruct1>>>(std::deque<std::shared_ptr<haxe::AnonStruct1>>{
			haxe::shared_anon<haxe::AnonStruct1>(123),
			haxe::shared_anon<haxe::AnonStruct1>(std::nullopt),
			haxe::shared_anon<haxe::AnonStruct1>(369)
		});
		tempRest3 = this1;
	};
	
	Main::testRestAny2(tempRest3);
	
	return Main::returnCode;
}
