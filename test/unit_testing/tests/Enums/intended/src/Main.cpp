#include "Main.h"

#include <iostream>
#include <memory>
#include <type_traits>
#include "haxe_Log.h"
#include "Std.h"

int Main::returnCode = 0;;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(std::make_shared<haxe::PosInfos>("", "test/unit_testing/tests/Enums/Main.hx",15, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

int main() {
	std::shared_ptr<MyEnum> a = MyEnum::Entry1();
	std::shared_ptr<MyEnum> b = MyEnum::Entry2(123);
	std::shared_ptr<MyEnum> c = MyEnum::Entry3("Test");
	
	switch(b->index) {
	
		case 0: {
			Main::assert(false, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 27, "main"));
			break;
		}
		case 1: {
			int _g = b->getEntry2().i;
			{
				int i = _g;
				{
					haxe::Log::trace(Std::string(i), std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 29, "main"));
					Main::assert(i == 123, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 30, "main"));
				};
			};
			break;
		}
		case 2: {
			std::string _g = b->getEntry3().s;
			{
				std::string s = _g;
				Main::assert(false, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 32, "main"));
			};
			break;
		}
	};
	switch(c->index) {
	
		case 0: {
			Main::assert(false, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 36, "main"));
			break;
		}
		case 1: {
			int _g = c->getEntry2().i;
			{
				int i = _g;
				Main::assert(false, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 37, "main"));
			};
			break;
		}
		case 2: {
			std::string _g = c->getEntry3().s;
			{
				std::string s = _g;
				{
					haxe::Log::trace(s, std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 39, "main"));
					Main::assert(s == "Test", std::make_shared<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 40, "main"));
				};
			};
			break;
		}
	};
	
	return Main::returnCode;
}
