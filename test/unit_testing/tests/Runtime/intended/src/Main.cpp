#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "haxe_ds_StringMap.h"
#include "haxe_Log.h"

using namespace std::string_literals;

void _Main::Main_Fields_::main() {
	std::cout << "test/unit_testing/tests/Runtime/Main.hx:4: Hello world!"s << std::endl;
	
	std::shared_ptr<haxe::ds::StringMap<std::string>> _g = std::make_shared<haxe::ds::StringMap<std::string>>();
	
	_g->set("fds"s, "fds"s);
	
	std::shared_ptr<haxe::ds::StringMap<std::string>> tempMap = _g;
	std::shared_ptr<haxe::ds::StringMap<std::string>> b = tempMap;
	std::shared_ptr<haxe::ds::StringMap<std::string>> b2 = _Main::Main_Fields_::bla();
	std::string tempString = b->toString();
	std::string tempString1 = b2->toString();
	
	haxe::Log::trace(tempString, haxe::shared_anon<haxe::PosInfos>("_Main.Main_Fields_"s, "test/unit_testing/tests/Runtime/Main.hx"s, 9, "main"s, std::make_shared<std::deque<haxe::DynamicToString>>(std::deque<haxe::DynamicToString>{
		tempString1
	})));
}

std::shared_ptr<haxe::ds::StringMap<std::string>> _Main::Main_Fields_::bla() {
	std::shared_ptr<haxe::ds::StringMap<std::string>> _g = std::make_shared<haxe::ds::StringMap<std::string>>();
	
	_g->set("1"s, "2"s);
	
	std::shared_ptr<haxe::ds::StringMap<std::string>> tempResult = _g;
	
	return tempResult;
}
