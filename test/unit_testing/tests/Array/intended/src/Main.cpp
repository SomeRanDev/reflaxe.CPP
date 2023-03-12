#include "Main.h"

#include <algorithm>
#include <deque>
#include <functional>
#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "HxArray.h"

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Array/Main.hx", 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

int main() {
	std::deque<int> arr = std::deque<int>();
	
	Main::assert(arr.size() == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 22, "main"));
	arr.push_back(0 + 1);
	arr.push_back(1 + 1);
	arr.push_back(2 + 1);
	Main::assert(arr.size() == 3, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 26, "main"));
	Main::assert(HxArray::concat<int>(arr, std::deque<int>{ 4, 5, 6 }).size() == 6, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 29, "main"));
	
	bool tempBool;
	
	{
		tempBool = (std::find(arr.begin(), arr.end(), 3) != arr.end());
	};
	
	Main::assert(tempBool, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 32, "main"));
	
	bool tempBool1;
	
	{
		tempBool1 = (std::find(arr.begin(), arr.end(), 5) != arr.end());
	};
	
	Main::assert(!tempBool1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 33, "main"));
	
	std::deque<int> arr2 = arr;
	
	Main::assert(arr == arr2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 37, "main"));
	Main::assert(arr == std::deque(arr2.begin(), arr2.end()), haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 40, "main"));
	Main::assert(HxArray::filter<int>(arr, [&](int i) mutable {
		return i != 1;
	}).size() == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 43, "main"));
	
	std::deque<int> arr3 = std::deque<int>{ 1, 2, 3, 4, 5 };
	int tempLeft;
	
	{
		int fromIndex = 0;
		tempLeft = HxArray::indexOf<int>(arr3, 2, fromIndex);
	};
	
	Main::assert(tempLeft == 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 47, "main"));
	HxArray::insert<int>(arr, 0, 0);
	Main::assert(arr.size() == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 51, "main"));
	Main::assert(arr[0] == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 52, "main"));
	Main::assert(arr[2] == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 53, "main"));
	HxArray::insert<int>(arr, -1, 4);
	Main::assert(arr.size() == 5, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 56, "main"));
	Main::assert(arr[4] == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 57, "main"));
	Main::assert(arr[2] == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 58, "main"));
	
	int total = 0;
	int it_current = 0;
	std::deque<int> it_array = arr;
	
	while(it_current < it_array.size()) {
		total += it_array[it_current++];
	};
	
	Main::assert(total == 10, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 66, "main"));
	Main::assert(HxArray::join<int>(arr, ", ") == "0, 1, 2, 3, 4", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 69, "main"));
	
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
	
	Main::assert(keyTotal == 10, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 83, "main"));
	Main::assert(doubleTotal == 20, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 84, "main"));
	
	std::deque<int> stack = std::deque<int>{ 84, 29, 655 };
	std::optional<int> tempMaybeNumber;
	
	{
		std::optional<int> result = stack.back();
		stack.pop_back();
		tempMaybeNumber = result;
	};
	
	Main::assert(tempMaybeNumber == 655, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 88, "main"));
	Main::assert(stack.size() == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 89, "main"));
	stack.push_back(333);
	Main::assert(stack[2] == 333, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 91, "main"));
	
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
		Main::assert(stack.size() == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 95, "main"));
		Main::assert(stack[0] == 29, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 96, "main"));
	} else {
		Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 98, "main"));
	};
	
	std::deque<int> ordered = std::deque<int>{ 3, 6, 9, 12 };
	
	std::reverse(ordered.begin(), ordered.end());
	Main::assert(ordered == std::deque<int>{ 12, 9, 6, 3 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 104, "main"));
	
	std::optional<int> tempMaybeNumber1;
	
	{
		std::optional<int> result = ordered.front();
		ordered.pop_front();
		tempMaybeNumber1 = result;
	};
	
	Main::assert(tempMaybeNumber1 == 12, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 107, "main"));
	
	std::deque<int> newArr = std::deque<int>{ 22, 44, 66, 88 };
	std::deque<int> tempLeft1;
	
	{
		std::optional<int> end = std::nullopt;
		tempLeft1 = HxArray::slice<int>(newArr, 1, end);
	};
	
	Main::assert(tempLeft1 == std::deque<int>{ 44, 66, 88 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 111, "main"));
	Main::assert(HxArray::slice<int>(newArr, 2, 3) == std::deque<int>{ 66 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 112, "main"));
	
	std::deque<int> tempLeft2;
	
	{
		std::optional<int> end = std::nullopt;
		tempLeft2 = HxArray::slice<int>(newArr, -1, end);
	};
	
	Main::assert(tempLeft2 == std::deque<int>{ 88 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 113, "main"));
	Main::assert(HxArray::slice<int>(newArr, -2, -1) == std::deque<int>{ 66, 88 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 114, "main"));
	Main::assert(HxArray::slice<int>(newArr, 0, 999999) == std::deque<int>{ 22, 44, 66, 88 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 115, "main"));
	Main::assert(HxArray::slice<int>(newArr, 999999, 0) == std::deque<int>{}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 116, "main"));
	
	std::deque<int> sortable = std::deque<int>{ 2, 7, 1, 4, 0, 4 };
	std::function<int(int, int)> f = [&](int a, int b) mutable {
		return a - b;
	};
	
	std::sort(sortable.begin(), sortable.end(), [&](int a, int b) mutable {
		return f(a, b) < 0;
	});
	Main::assert(sortable == std::deque<int>{ 0, 1, 2, 4, 4, 7 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 121, "main"));
	Main::assert(HxArray::splice<int>(sortable, 2, 1) == std::deque<int>{ 2 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 124, "main"));
	Main::assert(HxArray::splice<int>(sortable, 1, 3) == std::deque<int>{ 1, 4, 4 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 125, "main"));
	
	std::deque<int> newArr2 = std::deque<int>{ 12, 24, 36, 48, 60 };
	
	Main::assert(HxArray::splice<int>(newArr2, -2, 1) == std::deque<int>{ 48 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 128, "main"));
	Main::assert(HxArray::splice<int>(newArr2, -4, -1) == std::deque<int>{}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 129, "main"));
	Main::assert(HxArray::splice<int>(newArr2, 1, 999999) == std::deque<int>{ 24, 36, 60 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 130, "main"));
	Main::assert(HxArray::splice<int>(newArr2, 999999, 0) == std::deque<int>{}, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 131, "main"));
	Main::assert(newArr2 == std::deque<int>{ 12 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 132, "main"));
	Main::assert(HxArray::toString<int>(sortable) == "[0, 7]", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 135, "main"));
	
	std::deque<int> unfinished = std::deque<int>{ 3, 4, 5 };
	
	unfinished.push_front(2);
	unfinished.push_front(1);
	Main::assert(unfinished == std::deque<int>{ 1, 2, 3, 4, 5 }, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Array/Main.hx", 141, "main"));
	
	return Main::returnCode;
}
