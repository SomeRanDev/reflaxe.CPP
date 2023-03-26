#include "Main.h"

#include <iostream>
#include <memory>
#include <string>
#include "_AnonStructs.h"
#include "HxString.h"

using namespace std::string_literals;

int Main::returnCode = 0;

void Main::assert(bool b, std::optional<std::shared_ptr<haxe::PosInfos>> infos) {
	if(!b) {
		{
			auto temp = infos.value_or(haxe::shared_anon<haxe::PosInfos>("", "test/unit_testing/tests/String/Main.hx"s, 10, ""));
			std::cout << temp->fileName << ":" << temp->lineNumber << ": " << "Assert failed"s << std::endl;
		};
		Main::returnCode = 1;
	};
}

void Main::main() {
	std::string str = "Test"s;
	
	Main::assert(str == "Test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 17, "main"s));
	Main::assert(str.length() == 4, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 18, "main"s));
	Main::assert(str == "Test"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 19, "main"s));
	Main::assert(std::string(1, 70) == "F"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 21, "main"s));
	Main::assert(str[1] == 101, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 23, "main"s));
	Main::assert(str.find("es"s) == 1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 25, "main"s));
	Main::assert(str.find("Hey"s) == -1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 26, "main"s));
	Main::assert(str.find("Te"s, 2) == -1, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 27, "main"s));
	Main::assert(str.rfind("Te"s) == 0, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 29, "main"s));
	Main::assert((*HxString::split(str, "s"s))[0] == "Te"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 31, "main"s));
	Main::assert(HxString::split(str, "e"s)->size() == 2, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 32, "main"s));
	
	std::string str2 = "Hello, World!"s;
	
	Main::assert(str2.substr(7, 5) == "World"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 35, "main"s));
	
	std::string tempLeft;
	
	if(12 < 0) {
		tempLeft = str2.substr(7);
	} else {
		tempLeft = str2.substr(7, 12 - 7);
	};
	
	Main::assert(tempLeft == "World"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 36, "main"s));
	Main::assert(HxString::toLowerCase(str2) == "hello, world!"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 38, "main"s));
	Main::assert(HxString::toUpperCase(str2) == "HELLO, WORLD!"s, haxe::shared_anon<haxe::PosInfos>("Main"s, "test/unit_testing/tests/String/Main.hx"s, 39, "main"s));
	
	if(Main::returnCode != 0) {
		exit(Main::returnCode);
	};
}
