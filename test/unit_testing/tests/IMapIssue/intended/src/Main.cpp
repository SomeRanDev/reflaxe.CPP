#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "haxe_Constraints.h"
#include "haxe_ds_StringMap.h"
#include "haxe_Log.h"

using namespace std::string_literals;

Main::Main(): _order_id(generate_order_id()) {
	
}

void Main::bla() {
	this->testMap = std::make_shared<haxe::ds::StringMap<int>>();
	
	{
		std::shared_ptr<haxe::IMap<std::string, int>> this1 = this->testMap;
		this1->set("test"s, 123);
		123;
	};
	
	std::cout << "test/unit_testing/tests/IMapIssue/Main.hx:10: Test"s << std::endl;
	
	std::string tempString;
	
	{
		std::shared_ptr<haxe::IMap<std::string, int>> this1 = this->testMap;
		tempString = this1->toString();
	};
	
	haxe::Log::trace(tempString, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/IMapIssue/Main.hx"s, 11, "bla"s));
}

void Main::main() {
	std::shared_ptr<Main> a = std::make_shared<Main>();
	
	a->bla();
}
