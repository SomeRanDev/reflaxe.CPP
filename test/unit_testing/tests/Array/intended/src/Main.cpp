#include "Main.h"

#include <algorithm>
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
	std::deque<int> arr = std::deque<int>();
	
	Main::assert(arr.size() == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 20, "main"s));
	arr.push_back(0 + 1);
	arr.push_back(1 + 1);
	arr.push_back(2 + 1);
	Main::assert(arr.size() == 3, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 24, "main"s));
	Main::assert(HxArray::concat<int>(arr, std::deque<int>{ 4, 5, 6 }).size() == 6, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 27, "main"s));
	
	bool tempBool;
	
	{
		tempBool = (std::find(arr.begin(), arr.end(), 3) != arr.end());
	};
	
	Main::assert(tempBool, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 30, "main"s));
	
	bool tempBool1;
	
	{
		tempBool1 = (std::find(arr.begin(), arr.end(), 5) != arr.end());
	};
	
	Main::assert(!tempBool1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 31, "main"s));
	
	std::deque<int> arr2 = arr;
	
	Main::assert(arr == arr2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 35, "main"s));
	Main::assert(arr == std::deque(arr2.begin(), arr2.end()), haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 38, "main"s));
	Main::assert(HxArray::filter<int>(arr, [&](int i) mutable {
		return i != 1;
	}).size() == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 41, "main"s));
	
	std::deque<int> arr3 = std::deque<int>{ 1, 2, 3, 4, 5 };
	int tempLeft;
	
	{
		int fromIndex = 0;
		tempLeft = HxArray::indexOf<int>(arr3, 2, fromIndex);
	};
	
	Main::assert(tempLeft == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 45, "main"s));
	HxArray::insert<int>(arr, 0, 0);
	Main::assert(arr.size() == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 49, "main"s));
	Main::assert(arr[0] == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 50, "main"s));
	Main::assert(arr[2] == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 51, "main"s));
	HxArray::insert<int>(arr, -1, 4);
	Main::assert(arr.size() == 5, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 54, "main"s));
	Main::assert(arr[4] == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 55, "main"s));
	Main::assert(arr[2] == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 56, "main"s));
	
	int total = 0;
	int it_current = 0;
	std::deque<int> it_array = arr;
	
	while(it_current < it_array.size()) {
		total += it_array[it_current++];
	};
	
	Main::assert(total == 10, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 64, "main"s));
	Main::assert(HxArray::join<int>(arr, ", "s) == "0, 1, 2, 3, 4"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 67, "main"s));
	
	std::deque<int> doubleArr = HxArray::map<int, int>(arr, [&](int i) mutable {
		return i * 2;
	});
	int keyTotal = 0;
	int doubleTotal = 0;
	int kvit_current = 0;
	std::deque<int> kvit_array = doubleArr;
	
	while(kvit_current < kvit_array.size()) {
		int o_value;
		int o_key;
		o_value = kvit_array[kvit_current];
		o_key = kvit_current++;
		keyTotal += o_key;
		doubleTotal += o_value;
	};
	
	Main::assert(keyTotal == 10, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 81, "main"s));
	Main::assert(doubleTotal == 20, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 82, "main"s));
	
	std::deque<int> stack = std::deque<int>{ 84, 29, 655 };
	std::optional<int> tempMaybeNumber;
	
	{
		std::optional<int> result = stack.back();
		stack.pop_back();
		tempMaybeNumber = result;
	};
	
	Main::assert(tempMaybeNumber == 655, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 86, "main"s));
	Main::assert(stack.size() == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 87, "main"s));
	stack.push_back(333);
	Main::assert(stack[2] == 333, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 89, "main"s));
	
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
			stack.erase(stack.begin() + index);
			tempCond = true;
		};
	};
	
	if(tempCond) {
		Main::assert(stack.size() == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 93, "main"s));
		Main::assert(stack[0] == 29, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 94, "main"s));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 96, "main"s));
	};
	
	std::deque<int> ordered = std::deque<int>{ 3, 6, 9, 12 };
	
	std::reverse(ordered.begin(), ordered.end());
	Main::assert(ordered == std::deque<int>{ 12, 9, 6, 3 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 102, "main"s));
	
	std::optional<int> tempMaybeNumber1;
	
	{
		std::optional<int> result = ordered.front();
		ordered.pop_front();
		tempMaybeNumber1 = result;
	};
	
	Main::assert(tempMaybeNumber1 == 12, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 105, "main"s));
	
	std::deque<int> newArr = std::deque<int>{ 22, 44, 66, 88 };
	std::deque<int> tempLeft1;
	
	{
		std::optional<int> end = std::nullopt;
		tempLeft1 = HxArray::slice<int>(newArr, 1, end);
	};
	
	Main::assert(tempLeft1 == std::deque<int>{ 44, 66, 88 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 109, "main"s));
	Main::assert(HxArray::slice<int>(newArr, 2, 3) == std::deque<int>{ 66 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 110, "main"s));
	
	std::deque<int> tempLeft2;
	
	{
		std::optional<int> end = std::nullopt;
		tempLeft2 = HxArray::slice<int>(newArr, -1, end);
	};
	
	Main::assert(tempLeft2 == std::deque<int>{ 88 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 111, "main"s));
	Main::assert(HxArray::slice<int>(newArr, -2, -1) == std::deque<int>{ 66, 88 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 112, "main"s));
	Main::assert(HxArray::slice<int>(newArr, 0, 999999) == std::deque<int>{ 22, 44, 66, 88 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 113, "main"s));
	Main::assert(HxArray::slice<int>(newArr, 999999, 0) == std::deque<int>{}, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 114, "main"s));
	
	std::deque<int> sortable = std::deque<int>{ 2, 7, 1, 4, 0, 4 };
	std::function<int(int, int)> f = [&](int a, int b) mutable {
		return a - b;
	};
	
	std::sort(sortable.begin(), sortable.end(), [&](int a, int b) mutable {
		return f(a, b) < 0;
	});
	Main::assert(sortable == std::deque<int>{ 0, 1, 2, 4, 4, 7 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 119, "main"s));
	Main::assert(HxArray::splice<int>(sortable, 2, 1) == std::deque<int>{ 2 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 122, "main"s));
	Main::assert(HxArray::splice<int>(sortable, 1, 3) == std::deque<int>{ 1, 4, 4 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 123, "main"s));
	
	std::deque<int> newArr2 = std::deque<int>{ 12, 24, 36, 48, 60 };
	
	Main::assert(HxArray::splice<int>(newArr2, -2, 1) == std::deque<int>{ 48 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 126, "main"s));
	Main::assert(HxArray::splice<int>(newArr2, -4, -1) == std::deque<int>{}, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 127, "main"s));
	Main::assert(HxArray::splice<int>(newArr2, 1, 999999) == std::deque<int>{ 24, 36, 60 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 128, "main"s));
	Main::assert(HxArray::splice<int>(newArr2, 999999, 0) == std::deque<int>{}, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 129, "main"s));
	Main::assert(newArr2 == std::deque<int>{ 12 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 130, "main"s));
	Main::assert(HxArray::toString<int>(sortable) == "[0, 7]"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 133, "main"s));
	
	std::deque<int> unfinished = std::deque<int>{ 3, 4, 5 };
	
	unfinished.push_front(2);
	unfinished.push_front(1);
	Main::assert(unfinished == std::deque<int>{ 1, 2, 3, 4, 5 }, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/Array/Main.hx"s, 139, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
