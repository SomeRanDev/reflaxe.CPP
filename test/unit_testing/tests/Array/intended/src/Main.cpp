#include "Main.h"

#include <algorithm>
#include <cstdlib>
#include <deque>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "HxArray.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Array/Main.hx"s, 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::shared_ptr<std::deque<int>> arr = std::make_shared<std::deque<int>>();
	
	Main::assert((int)(arr->size()) == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 20, "main"s));
	arr->push_back(0 + 1);
	arr->push_back(1 + 1);
	arr->push_back(2 + 1);
	Main::assert((int)(arr->size()) == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 24, "main"s));
	Main::assert((int)(HxArray::concat<int>(arr, std::make_shared<std::deque<int>>(std::deque<int>{ 4, 5, 6 }))->size()) == 6, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 27, "main"s));
	
	bool tempBool;
	
	{
		tempBool = (std::find(arr->begin(), arr->end(), 3) != arr->end());
	};
	
	Main::assert(tempBool, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 30, "main"s));
	
	bool tempBool1;
	
	{
		tempBool1 = (std::find(arr->begin(), arr->end(), 5) != arr->end());
	};
	
	Main::assert(!tempBool1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 31, "main"s));
	
	std::shared_ptr<std::deque<int>> arr2 = arr;
	
	Main::assert((*arr) == (*arr2), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 35, "main"s));
	
	std::shared_ptr<std::deque<int>> tempRight;
	
	{
		std::shared_ptr<std::deque<int>> result = std::make_shared<std::deque<int>>(std::deque<int>{});
		{
			int _g = 0;
			std::shared_ptr<std::deque<int>> _g1 = arr2;
			while(_g < (int)(_g1->size())) {
				int obj = (*_g1)[_g];
				
				++_g;
				result->push_back(obj);
			};
		};
		tempRight = result;
	};
	
	Main::assert((*arr) == (*tempRight), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 36, "main"s));
	Main::assert((int)(HxArray::filter<int>(arr, [&](int i) mutable {
		return i != 1;
	})->size()) == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 39, "main"s));
	
	std::shared_ptr<std::deque<int>> arr3 = std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2, 3, 4, 5 });
	int tempLeft;
	
	{
		int fromIndex = 0;
		tempLeft = HxArray::indexOf<int>(arr3, 2, fromIndex);
	};
	
	Main::assert(tempLeft == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 43, "main"s));
	HxArray::insert<int>(arr, 0, 0);
	Main::assert((int)(arr->size()) == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 47, "main"s));
	Main::assert((*arr)[0] == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 48, "main"s));
	Main::assert((*arr)[2] == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 49, "main"s));
	HxArray::insert<int>(arr, -1, 4);
	Main::assert((int)(arr->size()) == 5, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 52, "main"s));
	Main::assert((*arr)[4] == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 53, "main"s));
	Main::assert((*arr)[2] == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 54, "main"s));
	
	int total = 0;
	int it_current = 0;
	std::shared_ptr<std::deque<int>> it_array = arr;
	
	while(it_current < (int)(it_array->size())) {
		total += (*it_array)[it_current++];
	};
	
	Main::assert(total == 10, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 62, "main"s));
	Main::assert(HxArray::join<int>(arr, ", "s) == "0, 1, 2, 3, 4"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 65, "main"s));
	
	std::shared_ptr<std::deque<int>> doubleArr = HxArray::map<int, int>(arr, [&](int i) mutable {
		return i * 2;
	});
	int keyTotal = 0;
	int doubleTotal = 0;
	int kvit_current = 0;
	std::shared_ptr<std::deque<int>> kvit_array = doubleArr;
	
	while(kvit_current < (int)(kvit_array->size())) {
		int o_value;
		int o_key;
		
		o_value = (*kvit_array)[kvit_current];
		o_key = kvit_current++;
		keyTotal += o_key;
		doubleTotal += o_value;
	};
	
	Main::assert(keyTotal == 10, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 79, "main"s));
	Main::assert(doubleTotal == 20, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 80, "main"s));
	
	std::shared_ptr<std::deque<int>> stack = std::make_shared<std::deque<int>>(std::deque<int>{ 84, 29, 655 });
	std::optional<int> tempMaybeNumber;
	
	{
		std::optional<int> result = stack->back();
		stack->pop_back();
		tempMaybeNumber = result;
	};
	
	Main::assert(tempMaybeNumber == 655, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 84, "main"s));
	Main::assert((int)(stack->size()) == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 85, "main"s));
	stack->push_back(333);
	Main::assert((*stack)[2] == 333, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 87, "main"s));
	
	bool tempCond;
	
	{
		int tempNumber;
		{
			int fromIndex = 0;
			tempNumber = HxArray::indexOf<int>(stack, 84, fromIndex);
		};
		int index = tempNumber;
		if(index < 0) {
			tempCond = false;
		} else {
			stack->erase(stack->begin() + index);
			tempCond = true;
		};
	};
	
	if(tempCond) {
		Main::assert((int)(stack->size()) == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 91, "main"s));
		Main::assert((*stack)[0] == 29, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 92, "main"s));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 94, "main"s));
	};
	
	std::shared_ptr<std::deque<int>> ordered = std::make_shared<std::deque<int>>(std::deque<int>{ 3, 6, 9, 12 });
	
	std::reverse(ordered->begin(), ordered->end());
	Main::assert((*ordered) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 12, 9, 6, 3 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 100, "main"s));
	
	std::optional<int> tempMaybeNumber1;
	
	{
		std::optional<int> result = ordered->front();
		ordered->pop_front();
		tempMaybeNumber1 = result;
	};
	
	Main::assert(tempMaybeNumber1 == 12, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 103, "main"s));
	
	std::shared_ptr<std::deque<int>> newArr = std::make_shared<std::deque<int>>(std::deque<int>{ 22, 44, 66, 88 });
	std::shared_ptr<std::deque<int>> tempLeft1;
	
	{
		std::optional<int> end = std::nullopt;
		tempLeft1 = HxArray::slice<int>(newArr, 1, end);
	};
	
	Main::assert((*tempLeft1) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 44, 66, 88 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 107, "main"s));
	Main::assert((*HxArray::slice<int>(newArr, 2, 3)) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 66 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 108, "main"s));
	
	std::shared_ptr<std::deque<int>> tempLeft2;
	
	{
		std::optional<int> end = std::nullopt;
		tempLeft2 = HxArray::slice<int>(newArr, -1, end);
	};
	
	Main::assert((*tempLeft2) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 88 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 109, "main"s));
	Main::assert((*HxArray::slice<int>(newArr, -2, -1)) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 66 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 110, "main"s));
	Main::assert((*HxArray::slice<int>(newArr, 0, 999999)) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 22, 44, 66, 88 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 111, "main"s));
	Main::assert((*HxArray::slice<int>(newArr, 999999, 0)) == (*std::make_shared<std::deque<int>>(std::deque<int>{})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 112, "main"s));
	
	std::shared_ptr<std::deque<int>> sortable = std::make_shared<std::deque<int>>(std::deque<int>{ 2, 7, 1, 4, 0, 4 });
	std::function<int(int, int)> f = [&](int a, int b) mutable {
		return a - b;
	};
	
	std::sort(sortable->begin(), sortable->end(), [&](int a, int b) mutable {
		return f(a, b) < 0;
	});
	Main::assert((*sortable) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 0, 1, 2, 4, 4, 7 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 117, "main"s));
	Main::assert((*HxArray::splice<int>(sortable, 2, 1)) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 2 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 120, "main"s));
	Main::assert((*HxArray::splice<int>(sortable, 1, 3)) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 1, 4, 4 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 121, "main"s));
	
	std::shared_ptr<std::deque<int>> newArr2 = std::make_shared<std::deque<int>>(std::deque<int>{ 12, 24, 36, 48, 60 });
	
	Main::assert((*HxArray::splice<int>(newArr2, -2, 1)) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 48 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 124, "main"s));
	Main::assert((*HxArray::splice<int>(newArr2, -4, -1)) == (*std::make_shared<std::deque<int>>(std::deque<int>{})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 125, "main"s));
	Main::assert((*HxArray::splice<int>(newArr2, 1, 999999)) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 24, 36, 60 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 126, "main"s));
	Main::assert((*HxArray::splice<int>(newArr2, 999999, 0)) == (*std::make_shared<std::deque<int>>(std::deque<int>{})), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 127, "main"s));
	Main::assert((*newArr2) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 12 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 128, "main"s));
	Main::assert(HxArray::toString<int>(sortable) == "[0, 7]"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 131, "main"s));
	
	std::shared_ptr<std::deque<int>> unfinished = std::make_shared<std::deque<int>>(std::deque<int>{ 3, 4, 5 });
	
	unfinished->push_front(2);
	unfinished->push_front(1);
	Main::assert((*unfinished) == (*std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2, 3, 4, 5 })), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 137, "main"s));
	
	std::shared_ptr<std::deque<int>> itArr = std::make_shared<std::deque<int>>(std::deque<int>{ 1, 2, 3 });
	int itArrSum = 0;
	
	{
		int _g = 0;
		while(_g < (int)(itArr->size())) {
			int a = (*itArr)[_g];
			
			++_g;
			itArrSum += a;
		};
	};
	
	Main::assert(itArrSum == 6, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 145, "main"s));
	
	int itArrIt_current = 0;
	std::shared_ptr<std::deque<int>> itArrIt_array = itArr;
	
	itArrSum = 0;
	
	while(itArrIt_current < (int)(itArrIt_array->size())) {
		itArrSum += (*itArrIt_array)[itArrIt_current++];
	};
	
	Main::assert(itArrSum == 6, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 152, "main"s));
	
	std::shared_ptr<std::deque<int>> doubleArr2 = std::make_shared<std::deque<int>>(std::deque<int>{ 2, 4, 6 });
	int _g_current = 0;
	std::shared_ptr<std::deque<int>> _g_array = doubleArr2;
	
	while(_g_current < (int)(_g_array->size())) {
		int _g_value;
		int _g_key;
		
		_g_value = (*_g_array)[_g_current];
		_g_key = _g_current++;
		
		int index = _g_key;
		int value = _g_value;
		
		Main::assert((index + 1) * 2 == value, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 157, "main"s));
	};
	
	int doubleArrIt_current = 0;
	std::shared_ptr<std::deque<int>> doubleArrIt_array = doubleArr2;
	
	while(doubleArrIt_current < (int)(doubleArrIt_array->size())) {
		int temp_value;
		int temp_key;
		
		temp_value = (*doubleArrIt_array)[doubleArrIt_current];
		temp_key = doubleArrIt_current++;
		Main::assert((temp_key + 1) * 2 == temp_value, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 163, "main"s));
	};
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
