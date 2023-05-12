#include "haxe_NativeStackTrace.h"

#include <deque>
#include <memory>
#include <string>
#include "haxe_CallStack.h"
#include "HxString.h"

using namespace std::string_literals;

void haxe::NativeStackTrace::saveStack(std::any exception) {
	
}

std::shared_ptr<std::deque<haxe::NativeStackItem*>> haxe::NativeStackTrace::callStack() {
	return haxe::NativeStackItem::getStack();
}

std::shared_ptr<std::deque<haxe::NativeStackItem*>> haxe::NativeStackTrace::exceptionStack() {
	return haxe::NativeStackItem::getStack();
}

std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> haxe::NativeStackTrace::toHaxe(std::shared_ptr<std::deque<haxe::NativeStackItem*>> nativeStackTrace, int skip) {
	std::shared_ptr<std::deque<std::shared_ptr<haxe::StackItem>>> result = std::make_shared<std::deque<std::shared_ptr<haxe::StackItem>>>(std::deque<std::shared_ptr<haxe::StackItem>>{});
	int _g = 0;
	int _g1 = (int)(nativeStackTrace->size());
	
	while(_g < _g1) {
		int i = _g++;
		
		if(i <= skip) {
			continue;
		};
		
		haxe::NativeStackItem* item = (*nativeStackTrace)[i];
		
		{
			int _g2 = item->type;
			
			if(_g2 == 0) {
				std::shared_ptr<std::deque<std::string>> tempArray;
				std::string _this = item->data;
				
				tempArray = HxString::split(_this, "::"s);
				
				std::shared_ptr<std::deque<std::string>> str = tempArray;
				
				result->push_back(haxe::StackItem::FilePos(haxe::StackItem::Method((*str)[0], (*str)[1]), item->file, item->line, item->col));
			} else {
				result->push_back(haxe::StackItem::CFunction());
			};
		};
	};
	
	return result;
}
