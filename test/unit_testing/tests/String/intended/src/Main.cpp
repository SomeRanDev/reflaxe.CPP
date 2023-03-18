#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "HxString.h"

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/String/Main.hx", 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed" << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::string str = "Test";
	
	Main::assert(str == "Test", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 17, "main"));
	Main::assert(str.length() == 4, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 18, "main"));
	Main::assert(str == "Test", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 19, "main"));
	Main::assert(std::string(1, 70) == "F", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 21, "main"));
	Main::assert(str[1] == 101, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 23, "main"));
	Main::assert(str.find("es") == 1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 25, "main"));
	Main::assert(str.find("Hey") == -1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 26, "main"));
	Main::assert(str.find("Te", 2) == -1, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 27, "main"));
	Main::assert(str.rfind("Te") == 0, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 29, "main"));
	Main::assert(HxString::split(str, "s")[0] == "Te", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 31, "main"));
	Main::assert(HxString::split(str, "e").size() == 2, haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 32, "main"));
	
	std::string str2 = "Hello, World!";
	
	Main::assert(str2.substr(7, 5) == "World", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 35, "main"));
	
	std::string tempLeft;
	
	if(12 < 0) {
		tempLeft = str2.substr(7);
	} else {
		tempLeft = str2.substr(7, 12 - 7);
	};
	
	Main::assert(tempLeft == "World", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 36, "main"));
	Main::assert(HxString::toLowerCase(str2) == "hello, world!", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 38, "main"));
	Main::assert(HxString::toUpperCase(str2) == "HELLO, WORLD!", haxe::shared_anon<haxe::PosInfos>("Main", "test/unit_testing/tests/String/Main.hx", 39, "main"));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
