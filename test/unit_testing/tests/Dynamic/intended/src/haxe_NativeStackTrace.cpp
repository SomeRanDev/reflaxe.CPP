#include "haxe_NativeStackTrace.h"

#include <deque>
#include <memory>
#include "haxe_CallStack.h"

void haxe::NativeStackTrace::saveStack(std::any exception) {
	
}

std::shared_ptr<std::deque<haxe::NativeStackItemData>> haxe::NativeStackTrace::callStack() {
	return haxe::NativeStackItem::copyStack();
}

std::shared_ptr<std::deque<haxe::NativeStackItemData>> haxe::NativeStackTrace::exceptionStack() {
	return haxe::NativeStackItem::copyStack();
}

std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> haxe::NativeStackTrace::toHaxe(std::shared_ptr<std::deque<haxe::NativeStackItemData>> nativeStackTrace, int skip) {
	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> result = std::make_shared<std::deque<std::shared_ptr<haxe::StackItem>>>(std::deque<std::shared_ptr<haxe::StackItem>>{});
	int _g = 0;
	int _g1 = (int)(nativeStackTrace->size());
	
	while(_g < _g1) {
		int i = _g++;
		
		if(i <= skip) {
			continue;
		};
		
		haxe::NativeStackItemData item = (*nativeStackTrace)[i];
		
		result->push_back(haxe::StackItem::FilePos(haxe::StackItem::Method(item.classname, item.method), item.file, item.line, item.col));
	};
	
	return result;
}
