#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/Enums/Main.hx", 15, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::shared_ptr<MyEnum> a = MyEnum::Entry1();
	std::shared_ptr<MyEnum> b = MyEnum::Entry2(123);
	std::shared_ptr<MyEnum> c = MyEnum::Entry3("Test");
	
	switch(b->index) {
	
		case 0: {
			Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 26, "main"));
			break;
		}
		case 1: {
			int _g = b->getEntry2().i;
			{
				int i = _g;
				Main::assert(i == 123, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 28, "main"));
			};
			break;
		}
		case 2: {
			std::string _g = b->getEntry3().s;
			{
				std::string s = _g;
				Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 30, "main"));
			};
			break;
		}
	};
	switch(c->index) {
	
		case 0: {
			Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 34, "main"));
			break;
		}
		case 1: {
			int _g = c->getEntry2().i;
			{
				int i = _g;
				Main::assert(false, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 35, "main"));
			};
			break;
		}
		case 2: {
			std::string _g = c->getEntry3().s;
			{
				std::string s = _g;
				Main::assert(s == "Test", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/Enums/Main.hx", 37, "main"));
			};
			break;
		}
	};
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
