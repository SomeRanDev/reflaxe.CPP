#pragma once

#include <any>
#include <deque>
#include <memory>
#include <string>
#include "haxe_CallStack.h"


#define HCXX_STACK_METHOD(...) \
	auto ___s = haxe::NativeStackItem::method(__VA_ARGS__)

#define HCXX_LINE(line_num) \
	___s.line = line_num

namespace haxe {

class NativeStackItem {
public:
	std::string data;
	int type;

	std::string file;
	int line;
	int col;

	NativeStackItem(int type, std::string file, int line, int col, std::string data):
		data(data), type(type), file(file), line(line), col(col)
	{
		getStack()->push_back(this);
	}

	~NativeStackItem() {
		getStack()->pop_back();
	}

	static std::shared_ptr<std::deque<NativeStackItem*>> getStack() {
		static auto stack = std::make_shared<std::deque<NativeStackItem*>>();
		return stack;
	}

	static NativeStackItem method(std::string file, int line, int col, std::string classname, std::string method) {
		return NativeStackItem(0, file, line, col, classname + "::" + method);
	}
};

}



namespace haxe {

class NativeStackTrace {
public:
	static void saveStack(std::any exception);
	
	static std::shared_ptr<std::deque<haxe::NativeStackItem*>> callStack();
	
	static std::shared_ptr<std::deque<haxe::NativeStackItem*>> exceptionStack();
	
	static std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> toHaxe(std::shared_ptr<std::deque<haxe::NativeStackItem*>> nativeStackTrace, int skip = 0);
};

}
