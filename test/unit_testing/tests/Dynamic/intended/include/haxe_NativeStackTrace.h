#pragma once

#include <any>
#include <deque>
#include <memory>
#include <string>
#include "haxe_CallStack.h"


#define HCXX_STACK_METHOD(...) \
	haxe::NativeStackItem ___s(__VA_ARGS__)

#define HCXX_LINE(line_num) \
	___s.data.line = line_num

namespace haxe {

// Data for the call stack
struct NativeStackItemData {
	std::string classname;
	std::string method;

	std::string file;
	int line;
	int col;
};

// Manages the call stack data
class NativeStackItem {
public:
	NativeStackItemData data;

	// Generate an item at the start of a function
	NativeStackItem(std::string file, int line, int col, std::string classname, std::string method) {
		data.file = file;
		data.line = line;
		data.col = col;
		data.classname = classname;
		data.method = method;

		// Do not copy by value, use pointers to avoid multiple destructions
		getStack()->push_front(this);
	}

	// Once this object goes out of scope (the function is complete),
	// it removes itself from the static list.
	~NativeStackItem() {
		getStack()->pop_front();
	}

	// Hack to use static variable in header only class
	static std::shared_ptr<std::deque<NativeStackItem*>> getStack() {
		static auto stack = std::make_shared<std::deque<NativeStackItem*>>();
		return stack;
	}

	// Copy the data specifically (so copy/destruction doesn't occur on manager object)
	static std::shared_ptr<std::deque<NativeStackItemData>> copyStack() {
		auto result = std::make_shared<std::deque<NativeStackItemData>>();
		for(auto& item : *getStack()) {
			result->push_back(item->data);
		}
		return result;
	}
};

}



namespace haxe {

class NativeStackTrace {
public:
	static void saveStack(std::any exception);
	
	static std::shared_ptr<std::deque<haxe::NativeStackItemData>> callStack();
	
	static std::shared_ptr<std::deque<haxe::NativeStackItemData>> exceptionStack();
	
	static std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> toHaxe(std::shared_ptr<std::deque<haxe::NativeStackItemData>> nativeStackTrace, int skip = 0);
};

}


#include "dynamic/Dynamic_haxe_NativeStackTrace.h"


// Reflection info
#include "_TypeUtils.h"
namespace haxe {
	template<> struct _class<haxe::NativeStackTrace> {
		DEFINE_CLASS_TOSTRING
		using Dyn = haxe::Dynamic_haxe_NativeStackTrace;
		constexpr static _class_data<0, 4> data {"NativeStackTrace", {}, { "saveStack", "callStack", "exceptionStack", "toHaxe" }, true};
	};
}
