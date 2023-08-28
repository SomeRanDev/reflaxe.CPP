#include "Main.h"

#include <any>
#include <cstdlib>
#include <deque>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Rest.h"
#include "HxArray.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/RestArgs/Main.hx"s, 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::oneTwoThree(std::shared_ptr<haxe::_Rest::NativeRest<int>> numbers) {
	std::shared_ptr<std::deque<int>> tempLeft;

	{
		std::shared_ptr<std::deque<int>> result = std::make_shared<std::deque<int>>(std::deque<int>{});

		{
			int _g = 0;
			std::shared_ptr<std::deque<int>> _g1 = numbers;

			while(_g < (int)(_g1->size())) {
				int obj = (*_g1)[_g];

				++_g;

				{
					result->push_back(obj);
				};
			};
		};

		tempLeft = result;
	};

	Main::assert((*tempLeft) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2, 3 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 18, "oneTwoThree"s));
	Main::assert(HxArray::toString<int>(numbers.get()) == "[1, 2, 3]"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 19, "oneTwoThree"s));

	std::shared_ptr<std::deque<int>> tempArray;

	{
		std::shared_ptr<std::deque<int>> result = std::make_shared<std::deque<int>>(std::deque<int>{});

		{
			int _g = 0;
			std::shared_ptr<std::deque<int>> _g1 = numbers;

			while(_g < (int)(_g1->size())) {
				int obj = (*_g1)[_g];

				++_g;

				{
					result->push_back(obj);
				};
			};
		};

		tempArray = result;
	};

	tempArray->push_back(123);
	Main::assert(HxArray::toString<int>(tempArray.get()) == "[1, 2, 3, 123]"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 24, "oneTwoThree"s));

	int i = 1;
	int _g_current = 0;
	std::shared_ptr<haxe::_Rest::NativeRest<int>> _g_args = std::any_cast<std::shared_ptr<haxe::_Rest::NativeRest<int>>>(numbers);

	while(_g_current < (int)(_g_args->size())) {
		int tempNumber;

		{
			std::shared_ptr<haxe::_Rest::NativeRest<int>> this1 = _g_args;
			int index = _g_current++;

			tempNumber = (*this1)[index];
		};

		int a = tempNumber;

		Main::assert(a == i, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 29, "oneTwoThree"s));
		i++;
	};

	std::shared_ptr<std::deque<int>> tempLeft1;

	{
		std::shared_ptr<haxe::_Rest::NativeRest<int>> this1 = haxe::_Rest::Rest_Impl_::append(numbers, 4);
		std::shared_ptr<std::deque<int>> result = std::make_shared<std::deque<int>>(std::deque<int>{});

		{
			int _g = 0;
			std::shared_ptr<std::deque<int>> _g1 = this1;

			while(_g < (int)(_g1->size())) {
				int obj = (*_g1)[_g];

				++_g;

				{
					result->push_back(obj);
				};
			};
		};

		tempLeft1 = result;
	};

	Main::assert((*tempLeft1) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2, 3, 4 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 34, "oneTwoThree"s));

	std::shared_ptr<std::deque<int>> tempLeft2;

	{
		std::shared_ptr<haxe::_Rest::NativeRest<int>> this1 = haxe::_Rest::Rest_Impl_::prepend(numbers, 0);
		std::shared_ptr<std::deque<int>> result = std::make_shared<std::deque<int>>(std::deque<int>{});

		{
			int _g = 0;
			std::shared_ptr<std::deque<int>> _g1 = this1;

			while(_g < (int)(_g1->size())) {
				int obj = (*_g1)[_g];

				++_g;

				{
					result->push_back(obj);
				};
			};
		};

		tempLeft2 = result;
	};

	Main::assert((*tempLeft2) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 0, 1, 2, 3 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 37, "oneTwoThree"s));
}

void Main::testRest(std::shared_ptr<haxe::_Rest::NativeRest<std::string>> strings) {
	std::shared_ptr<std::deque<std::string>> tempLeft;

	{
		std::shared_ptr<std::deque<std::string>> result = std::make_shared<std::deque<std::string>>(std::deque<std::string>{});
		int _g = 0;
		std::shared_ptr<std::deque<std::string>> _g1 = strings;

		while(_g < (int)(_g1->size())) {
			std::string obj = (*_g1)[_g];

			++_g;
			result->push_back(obj);
		};

		tempLeft = result;
	};

	Main::assert((*tempLeft) == (*std::make_shared<std::deque<std::string>>(std::deque<std::string>{
		"one"s,
		"two"s,
		"three"s
	})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 42, "testRest"s));
}

void Main::testRestAny(std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>>> anys) {
	Main::assert((*std::any_cast<std::shared_ptr<std::deque<int>>>((*anys)[1]->data.value())) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 0, 500, 1000 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 47, "testRestAny"s));
	Main::assert((*std::any_cast<std::shared_ptr<std::deque<int>>>((*anys)[1]->data.value()))[1] == 500, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 48, "testRestAny"s));
	Main::assert((*std::any_cast<std::shared_ptr<std::deque<int>>>((*anys)[1]->data.value()))[2] == 1000, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 49, "testRestAny"s));
}

void Main::testRestAny2(std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct1>>> anys) {
	Main::assert((*anys)[0]->data == 123, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 54, "testRestAny2"s));
	Main::assert(!(*anys)[1]->data.has_value(), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 55, "testRestAny2"s));
	Main::assert((*anys)[2]->data == 369, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/RestArgs/Main.hx"s, 56, "testRestAny2"s));
}

void Main::main() {
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
			"one"s,
			"two"s,
			"three"s
		});
		tempRest1 = this1;
	};

	Main::testRest(tempRest1);

	std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>>> tempRest2;

	{
		std::shared_ptr<haxe::_Rest::NativeRest<std::shared_ptr<haxe::AnonStruct0>>> this1;

		this1 = std::make_shared<std::deque<std::shared_ptr<haxe::AnonStruct0>>>(std::deque<std::shared_ptr<haxe::AnonStruct0>>{
			haxe::shared_anon<haxe::AnonStruct0>(std::nullopt),
			haxe::shared_anon<haxe::AnonStruct0>(std::make_shared<std::deque<int>>(std::deque<int>{ 0, 500, 1000 }))
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

	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
